require 'spec_helper'

RSpec.describe ResourceKit::ResourceCollection do
  subject(:collection) { ResourceKit::ResourceCollection.new }

  describe '#action' do
    it 'yields an action to the block' do
      expect {|b| collection.action(:all, &b) }.to yield_with_args(instance_of(ResourceKit::Action))
    end

    it 'adds the action to the collection' do
      action = collection.action :all
      expect(collection).to include(action)
    end
  end

  describe '#find_action' do
    it 'returns the action with the name passed' do
      collection.action(:all)

      retrieved_action = collection.find_action(:all)

      expect(retrieved_action).to be_kind_of(ResourceKit::Action)
      expect(retrieved_action.name).to eq(:all)
    end
  end
end