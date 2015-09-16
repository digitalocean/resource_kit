require 'kartograph'

class Droplet
  attr_accessor :id, :name, :region, :size, :image
end

class DropletMapping
  include Kartograph::DSL

  kartograph do
    mapping Droplet
    root_key plural: 'droplets', singular: 'droplet', scopes: [:read]

    property :id, scopes: [:read]
    property :name, scopes: [:read, :create]
    property :size, scopes: [:read, :create]
    property :image, scopes: [:read, :create]
    property :region, scopes: [:read, :create]
  end
end

class DropletResource < ResourceKit::Resource
  resources do
    action :all do
      verb :get
      path '/v2/droplets'
      handler(200) { |response| DropletMapping.extract_collection(response.body, :read) }
    end

    action :find do
      verb :get
      path '/v2/droplets/:id'
      handler(200) { |response| DropletMapping.extract_single(response.body, :read) }
    end

    action :create do
      verb :post
      path '/v2/droplets'
      body { |object| DropletMapping.representation_for(:create, object) }
      handler(202) { |response| DropletMapping.extract_single(response.body, :read) }
    end

    action :update do
      verb :put
      path '/v2/droplets/123'
      body { |object| DropletMapping.representation_for(:create, object) }
      handler(200) { |response, object| DropletMapping.extract_into_object(object, response.body, :read) }
    end
  end
end

token = 'YOUR_ACCESS_TOKEN'
conn = Faraday.new(url: 'https://api.digitalocean.com', headers: { content_type: 'application/json', authorization: "Bearer #{token}" }) do |req|
  req.adapter :net_http
end

resource = DropletResource.new(connection: conn)

# Retrieve all droplets
puts resource.all
