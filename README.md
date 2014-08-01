# Resource Kit

Resource Kit provides tools to aid in making API Clients. Such as URL resolving, Request / Response layer, and more.

## Installation

Add this line to your application's Gemfile:

    gem 'resource_kit'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resource_kit

## Usage

This library recommends using [Kartograph](http://github.com/digitaloceancloud/kartograph) for representing and deserializing response bodies.
You'll see it in the examples provided below.

### Resource classes

Resource Kit provides a comprehensive but intuitive DSL where you describe the remote resources capabilities.
For example, where can I get a list of users? Where do I get a single user? How do I create a user?

When you're able to answer these questions, you can describe them in your resource class like this:

```ruby
class DropletResource < ResourceKit::Resource
  resources do
    default_handler(422) {|body| ErrorMapping.extract_single(body, :read) }
    default_handler(:ok, :created) {|body| DropletMapping.extract_single(body, :read) }

    # Defining actions will create instance methods on the resource class to call them.
    action :find do
      verb :get # get is assumed if this is omitted
      path '/droplets/:id'
      handler(200) {|body| DropletMapping.extract_single(body, :read) }
    end

    action :all do
      path '/droplets'
      handler(200) {|body| DropletMapping.extract_collection(body, :read) }
    end

    action :create do
      path '/droplets'
      verb :post
      body {|object| DropletMapping.representation_for(:create, object) } # Generate a response body from a passed object
      handler(202) {|body| DropletMapping.extract_single(body, :read) }
    end
  end
end
```

Now that we've described our resources. We can instantiate our class with a connection object. ResourceKit relies on the interface that Faraday provides. For example:

```ruby
connection = Faraday.new(url: 'http://api.digitalocean.com') do |req|
  f.adapter :net_http
end

resource = DropletResource.new(connection)
```

Now that we've instantiated a resource with our class, we can call the actions we've defined on it.

```
all_droplets = resource.all
single_droplet = resource.find(id: 123)
create = resource.create(Droplet.new)
```

### Nice to have's

Things we've thought about but just haven't implemented are:

* `action :find, 'PUT droplets/:id/restart'`


## Contributing

1. Fork it ( https://github.com/[my-github-username]/resource_kit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
