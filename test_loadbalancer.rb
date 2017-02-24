require "net/http"
require "uri"
require 'pp'

lb_url="http://10.0.0.11"

uri = URI.parse(lb_url)
requestCount = 100

response_hash = Hash.new(0)

(1..requestCount).each do |i|
  http = Net::HTTP.new(uri.host, uri.port)
  response = http.request(Net::HTTP::Get.new(uri.request_uri))
  response_hash[response["X-Backend-Server"]] += 1
end

response_hash.each do |key, value|
  pp "#{key} ====>  #{value}"
end
