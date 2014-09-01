require 'resource_kit'

class HTTPBinResource < ResourceKit::Resource
  resources do
    default_handler(:ok) { |response| response.body }

    get :ip, '/ip'
    get :status, '/status/:code'
  end
end

conn = Faraday.new(url: 'http://httpbin.org')
resource = HTTPBinResource.new(connection: conn)

puts resource.ip
puts
puts resource.status(code: 418)
