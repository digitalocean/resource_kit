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
  end
end