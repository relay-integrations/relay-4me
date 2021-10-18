#!/usr/bin/env ruby
require 'sdk4me/client'
require 'net/http'

def endpoint
  ENV['METADATA_API_URL']
end

def call_metadata_api(uri, req)
  req.basic_auth uri.user, uri.password
  begin
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end
  rescue StandardError => e
    LOG.error("Error from metadata service: #{e}")
    raise e
  end
  res
end

def send_relay_outputs(key, value)
  uri = URI("#{endpoint}/outputs/#{key}")
  req = Net::HTTP::Put.new(uri, { 'Content-Type' => 'application/json' })
  req.body = value.to_json
  res = call_metadata_api(uri, req)
  return res if res.is_a? Net::HTTPSuccess

  LOG.error("Error writing outputs: #{res.inspect} #{res.body}")
  exit(1)
end

def relay_inputs
  uri = URI("#{endpoint}/spec")
  req = Net::HTTP::Get.new(uri)
  res = call_metadata_api(uri, req)
  return JSON.parse(res.body).deep_transform_keys(&:to_sym) if res.is_a? Net::HTTPSuccess

  LOG.error("Error fetching metadata: #{res.inspect} #{res.body}")
  exit(1)
end

def lookup_si_id(si_name)
  # We use the search API instead of fetching all service instances and looping over them
  # by doing client.each('service_instances') do |si|
  # see https://developer.4me.com/v1/search/
  CLIENT.get('search', { q: si_name, types: 'service-instance' }).json.each do |si|
    next unless si[:title] == si_name # the search results have a title, not a name

    LOG.debug("Found service_instance_id #{si[:id]} for name #{si_name}")
    return si[:id]
  end
  false
end

spec = relay_inputs[:value]

LOG = Logger.new($stdout)
LOG.level = spec[:debug] ? Logger::DEBUG : Logger::INFO

LOG.debug("Spec: \n#{spec}")

connection = spec[:connection]

Sdk4me.configure do |config|
  config.logger = LOG
  config.host = connection[:host]
  config.account = connection[:account]
  config.access_token = connection[:accessToken]
end

CLIENT = Sdk4me::Client.new

my_id = CLIENT.get('me')[:id]

request = spec[:request]
si_id = request[:service_instance_id]
si_name = request[:service_instance_name]

unless si_id
  unless si_name
    LOG.error('One of `service_instance_id` or `service_instance_name` parameters is required')
    exit(1)
  end
  si_id = lookup_si_id(si_name)
  unless si_id
    LOG.error("Did not find service instance named `#{si_name}`")
    exit(1)
  end
  request[:service_instance_id] = si_id
end

response = CLIENT.post('requests', request.merge({ requested_by: my_id }))
unless response.valid?
  LOG.error("#{response.message}: #{response[:errors]}")
  exit(1)
end

LOG.info("New request created with id #{response[:id]}")
send_relay_outputs(:request, response.json)
