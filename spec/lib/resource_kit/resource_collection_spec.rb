require 'spec_helper'

RSpec.describe ResourceKit::ResourceCollection do
  subject(:collection) { ResourceKit::ResourceCollection.new }

  describe '#default_handler' do
    it 'adds the passed black to a hash of handlers on the resource collection' do
      handler_block = Proc.new { |b| 'whut whut' }
      collection.default_handler(:ok, :no_content, &handler_block)

      expect(collection.default_handlers[200]).to eq(handler_block)
      expect(collection.default_handlers[204]).to eq(handler_block)
    end
  end

  describe '#action' do
    it 'yields an action to the block' do
      expect { |b| collection.action(:all, &b) }.to yield_with_args(instance_of(ResourceKit::Action))
    end

    it 'adds the action to the collection' do
      action = collection.action :all
      expect(collection).to include(action)
    end

    it "accepts a second argument of VERB /resource" do
      action = collection.action :all, 'GET /v2/droplets'
      expect(action.verb).to eq :get
      expect(action.path).to eq '/v2/droplets'
      expect(action.name).to eq :all
    end

    context 'when default handlers have been specified on the collection' do
      let(:handler) { Proc.new { |response| 'sure' } }

      before { collection.default_handler(:ok, &handler) }

      it 'prepends the default handlers to the test' do
        action = collection.action(:all)
        expect(action.handlers[200]).to eq(handler)
      end
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