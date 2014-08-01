require 'spec_helper'

RSpec.describe ResourceKit::Action do
  subject(:action) { ResourceKit::Action.new(:bunk) }

  describe '#initialize' do
    it 'initializes with a name' do
      instance = ResourceKit::Action.new(:all)
      expect(instance.name).to eq(:all)
    end
  end

  describe '#verb' do
    it 'sets the verb' do
      action = described_class.new(:find)
      action.verb :get
      expect(action.verb).to be(:get)
    end
  end

  describe '#path' do
    it 'sets the path' do
      action = described_class.new(:find)
      action.path '/something/sammy'
      expect(action.path).to eq('/something/sammy')
    end
  end

  describe '#handler' do
    it 'adds a handler to the handlers' do
      expect { action.handler(202) { } }.to change(action.handlers, :size).from(0).to(1)
    end
  end

  describe '#handlers' do
    it 'returns a handler collection object' do
      collection = action.handlers
      expect(collection).to be_kind_of(Hash)
    end
  end

  describe '#body' do
    it 'stores a proc for handling requests with bodies' do
      handler = Proc.new {|object| 'whut whut' }
      action.body(&handler)

      expect(action.body).to be(handler)
    end
  end
end