require 'spec_helper'

RSpec.describe ResourceKit::Resource do
  describe '.resources' do
    subject(:resource) { Class.new(described_class) }

    it 'returns a resource collection' do
      expect(resource.resources).to be_kind_of(ResourceKit::ResourceCollection)
    end

    it 'yields a resource collection' do
      expect { |b| resource.resources(&b) }.to yield_with_args(instance_of(ResourceKit::ResourceCollection))
    end

    context 'action methods' do
      class DropletResource < described_class
        resources do
          action :find
          action :all
        end
      end

      subject(:droplet_resource) { DropletResource.new }

      it "defines the action method" do
        expect(droplet_resource).to respond_to(:find)
        expect(droplet_resource).to respond_to(:all)
      end
    end
  end

  describe '#initialize' do
    it 'initializes with a connection' do
      faraday = Faraday.new(url: 'http://lol.com')
      instance = ResourceKit::Resource.new(connection: faraday)

      expect(instance.connection).to be(faraday)
    end

    it 'initializes with an optional scope object' do
      connection = double('conn')
      scope = double('scope')

      instance = ResourceKit::Resource.new(connection: connection, scope: scope)

      expect(instance.connection).to be(connection)
      expect(instance.scope).to be(scope)
    end
  end

  describe '#action' do
    it 'returns the action for the name passed' do
      faraday = Faraday.new(url: 'http://lol.com')

      class DummyResource < described_class
        resources do
          action :find, 'GET /hello'
        end
      end

      instance = DummyResource.new(connection: faraday)

      expect(instance.action(:find)).to be_kind_of(ResourceKit::Action)
    end
  end
end
