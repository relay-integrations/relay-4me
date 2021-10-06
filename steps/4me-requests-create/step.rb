#!/usr/bin/env ruby
require 'sdk4me/client'
require 'net/http'

def metadata_uri
  endpoint = ENV['METADATA_API_URL']
  uri = URI("#{endpoint}/spec")
  uri
end

def send_relay_outputs(outputs)
  puts outputs
  endpoint = ENV['METADATA_API_URL']
  uri = URI("#{endpoint}/outputs/request")
  req = Net::HTTP::Put.new(uri, { 'Content-Type' => 'application/json' })
  req.body = outputs.to_json
  # req.body = outputs
  puts "\n\n***body: #{req.body}"
  req.basic_auth uri.user, uri.password
  begin
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end
  rescue StandardError => e
    puts "Error writing outputs: #{e}"
    raise e
  end
  unless res.is_a? Net::HTTPSuccess
    puts "Error writing outputs: #{res.inspect} #{res.body}"
    exit(1)
  end
end

def mock_data
  require 'yaml'
  puts "in mock_data"
  data = YAML.safe_load(File.read("test-metadata-local.yaml"))["runs"]["1"]["steps"]["default"]["spec"]
  puts "data : #{data}"
  { value: data }
end

def relay_inputs
  if ENV['RELAY_MOCK']
    mock_data.deep_transform_keys(&:to_sym)
  else
    uri = metadata_uri
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
    if res.is_a? Net::HTTPSuccess
      JSON.parse(res.body).deep_transform_keys(&:to_sym)
    else
      puts "Error fetching metadata: #{res.inspect} #{res.body}"
      exit(1)
    end
  end
end

log = Logger.new(STDOUT)
log.level = Logger::INFO

spec = relay_inputs[:value]
connection = spec[:connection]

Sdk4me.configure do |config|
  config.logger = log
  config.host = connection[:host]
  config.access_token = connection[:access_token]
  config.account = connection[:account]
end

client = Sdk4me::Client.new
response = client.get('me')
# puts response[:primary_email]
# puts JSON.pretty_generate(response.json)
my_id = response[:id]

# requests = client.each('requests') do |request|
#  puts "#{request[:id]} #{request[:subject]}"
# end

# service_instances = client.each('service_instances') do |service_instance|
# puts "#{service_instance[:id]} #{service_instance[:name]}"
# end

request = spec[:request]

response = Sdk4me::Client.new.post('requests', {
                                     requested_by: my_id,
                                     category: request[:category],
                                     subject: request[:subject],
                                     impact: request[:impact],
                                     service_instance: request[:service_instance_id]
                                   })

if response.valid?
  puts "New request created with id #{response[:id]}"
  send_relay_outputs(response)
else
  puts response.message, response[:errors]
end
