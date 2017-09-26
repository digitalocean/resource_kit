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
    default_handler(422) { |response| ErrorMapping.extract_single(response.body, :read) }
    default_handler(:ok, :created) { |response| DropletMapping.extract_single(response.body, :read) }
    default_handler { |response| raise "Unexpected response status #{response.status}... #{response.body}" }

    # Defining actions will create instance methods on the resource class to call them.
    action :find do
      verb :get # get is assumed if this is omitted
      path '/droplets/:id'
      handler(200) { |response| DropletMapping.extract_single(response.body, :read) }
    end

    action :all do
      path '/droplets'
      handler(200) { |body| DropletMapping.extract_collection(body, :read) }
    end

    action :create do
      path '/droplets'
      verb :post
      body { |object| DropletMapping.representation_for(:create, object) } # Generate a response body from a passed object
      handler(202) { |response| DropletMapping.extract_single(response.body, :read) }
    end
  end
end
```

You also have the option to use a shorter version to describe actions like this:

```ruby
class DropletResource < ResourceKit::Resource
  resources do
    action :all, 'GET /v2/droplets' do
      handler(:ok) { |response| DropletMapping.extract_collection(response.body, :read) }
    end
  end
end
```

Instead of using `#action`, you can use any of the supported HTTP verb methods including `#get`, `#post`, `#put`, `#delete`, `#head`, `#patch`, and `#options`. Thus, the above example can be also written as:

```ruby
class DropletResource < ResourceKit::Resource
  resources do
    get :all, '/v2/droplets' do
      handler(:ok) { |response| DropletMapping.extract_collection(response.body, :read) }
    end
  end
end
```

Now that we've described our resources. We can instantiate our class with a connection object. ResourceKit relies on the interface that Faraday provides. For example:

```ruby
conn = Faraday.new(url: 'http://api.digitalocean.com') do |req|
  req.adapter :net_http
end

resource = DropletResource.new(connection: conn)
```

Now that we've instantiated a resource with our class, we can call the actions we've defined on it.

```
all_droplets = resource.all
single_droplet = resource.find(id: 123)
create = resource.create(Droplet.new)
```

## Scope

ResourceKit classes give you the option to pass in an optional scope object, so that you may interact with the resource with it that way.

For example, you may want to use this for nested resources:

```ruby
class CommentResource < ResourceKit::Resource
  resources do
    action :all do
      path { "/users/#{user_id}/comments" }
      handler(200) { |resp| CommentMapping.extract_collection(resp.body, :read) }
    end
  end

  def user_id
    scope.user_id
  end
end

user = User.find(123)
resource = CommentResource.new(connection: conn, scope: user)
comments = resource.all #=> Will fetch from /users/123/comments
```

## Test Helpers

ResourceKit supplys test helpers that assist in certain things you'd want your resource classes to do.

Make sure you:

    require 'resource_kit/testing'

Testing a certain action:

```ruby
# Tag the spec with resource_kit to bring in the helpers
RSpec.describe MyResourceClass, resource_kit: true do
  it 'has an all action' do
    expect(MyResourceClass).to have_action(:all).that_handles(:ok, :no_content).at_path('/users')
  end

  it 'handles a 201 with response body' do
    expect(MyResourceClass).to handle_response(:create).with(status: 201, body: '{"users":[]}') do |handled|
      expect(handled).to all(be_kind_of(User))
    end
  end
end
```

### Nice to have's

Things we've thought about but just haven't implemented are:

* Pagination capabilities


## Contributing

1. Fork it ( https://github.com/digitaloceancloud/resource_kit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Releasing


