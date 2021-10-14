#!/usr/bin/env ruby
require 'sdk4me/client'
require 'net/http'

def endpoint
  ENV['METADATA_API_URL']
end

def send_relay_outputs(key, value)
  uri = URI("#{endpoint}/outputs/#{key}")
  req = Net::HTTP::Put.new(uri, { 'Content-Type' => 'application/json' })
  req.body = value.to_json
  req.basic_auth uri.user, uri.password
  begin
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end
  rescue StandardError => e
    log.error("Error writing outputs: #{e}")
    raise e
  end
  return res if res.is_a? Net::HTTPSuccess

  log.error("Error writing outputs: #{res.inspect} #{res.body}")
  exit(1)
end

def relay_inputs
  uri = URI("#{endpoint}/spec")
  req = Net::HTTP::Get.new(uri)
  req.basic_auth uri.user, uri.password
  begin
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end
  rescue StandardError => e
    log.error("Error fetching metadata: #{e}")
    raise e
  end
  return JSON.parse(res.body).deep_transform_keys(&:to_sym) if res.is_a? Net::HTTPSuccess

  log.error("Error fetching metadata: #{res.inspect} #{res.body}")
  exit(1)
end


spec = relay_inputs[:value]

log = Logger.new($stdout)
log.level = spec[:debug] ? Logger::DEBUG : Logger::INFO

connection = spec[:connection]

log.debug("connection: #{connection}")

Sdk4me.configure do |config|
  config.logger = log
  config.host = connection[:host]
  config.account = connection[:account]
  config.access_token = connection[:accessToken]
end

client = Sdk4me::Client.new

my_id = client.get('me')[:id]

request = spec[:request]

response = Sdk4me::Client.new.post('requests', request.merge({ requested_by: my_id }))

if response.valid?
  log.info("New request created with id #{response[:id]}")
  send_relay_outputs(:request, response.json)
else
  log.error(response.message, response[:errors])
end