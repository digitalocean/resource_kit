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

    it 'sets the path to a block when passed' do
      action = described_class.new(:find)
      proc = Proc.new { '/users/:id/comments' }
      action.path(&proc)

      expect(action.path).to be(proc)
    end
  end

  describe '#handler' do
    it 'adds a handler to the handlers' do
      expect { action.handler(202) { } }.to change(action.handlers, :size).from(0).to(1)
    end

    it 'adds the correct status code when using a symbol' do
      action.handler(:ok) {}
      expect(action.handlers).to have_key(200)
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
      handler = Proc.new { |object| 'whut whut' }
      action.body(&handler)

      expect(action.body).to be(handler)
    end
  end

  describe '#query_keys' do
    it 'allows setting known query parameters that we should append to the URL' do
      action.query_keys :per_page, :page
      expect(action.query_keys).to include(:per_page, :page)
    end
  end

  describe '#before_request' do
    context 'with a block' do
      it 'sets a block to happen before the request happens' do
        proc = Proc.new {}
        action.before_request(&proc)
        expect(action.hooks[:before]).to include(proc)
      end
    end

    context 'with a symbol' do
      it 'adds the symbol to the before hooks' do
        action.before_request(:foo)
        expect(action.hooks[:before]).to include(:foo)
      end
    end
  end
end