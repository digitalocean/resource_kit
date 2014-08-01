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
      end
    end
  end
end