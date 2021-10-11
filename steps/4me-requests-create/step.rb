#!/usr/bin/env ruby
require 'sdk4me/client'
require 'net/http'

def send_relay_outputs(outputs)
  endpoint = ENV['METADATA_API_URL']
  uri = URI("#{endpoint}/outputs/request")
  req = Net::HTTP::Put.new(uri, { 'Content-Type' => 'application/json' })
  req.body = outputs.to_json
  req.basic_auth uri.user, uri.password
  begin
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end
  rescue StandardError => e
    puts "Error writing outputs: #{e}"
    raise e
  end
  return res if res.is_a? Net::HTTPSuccess

  puts "Error writing outputs: #{res.inspect} #{res.body}"
  exit(1)
end

def mock_data
  require 'yaml'
  data = YAML.safe_load(File.read('test-metadata-local.yaml'))['runs']['1']['steps']['default']['spec']
  puts "data : #{data}"
  { value: data }
end

def relay_inputs
  return mock_data.deep_transform_keys(&:to_sym) if ENV['RELAY_MOCK']

  endpoint = ENV['METADATA_API_URL']
  uri = URI("#{endpoint}/spec")
  req = Net::HTTP::Get.new(uri)
  req.basic_auth uri.user, uri.password
  begin
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end
  rescue StandardError => e
    puts "Error fetching metadata: #{e}"
    raise e
  end
  return JSON.parse(res.body).deep_transform_keys(&:to_sym) if res.is_a? Net::HTTPSuccess

  puts "Error fetching metadata: #{res.inspect} #{res.body}"
  exit(1)
end

log = Logger.new($stdout)
log.level = Logger::DEBUG

spec = relay_inputs[:value]
connection = spec[:connection]

log.debug("connection: #{connection}")
log.debug("connection[:host]: #{connection[:host]}")
log.debug("connection[:account]: #{connection[:account]}")
log.debug("connection[:accessToken] (class): #{connection[:accessToken]} ( #{connection[:accessToken].class} )")

Sdk4me.configure do |config|
  config.logger = log
  config.host = connection[:host]
  config.account = connection[:account]
  config.access_token = connection[:accessToken]
end

client = Sdk4me::Client.new
response = client.get('me')

my_id = response[:id]

request = spec[:request]

response = Sdk4me::Client.new.post('requests', request.merge({ requested_by: my_id }))

if response.valid?
  puts "New request created with id #{response[:id]}"
  send_relay_outputs(response)
else
  puts response.message, response[:errors]
end
