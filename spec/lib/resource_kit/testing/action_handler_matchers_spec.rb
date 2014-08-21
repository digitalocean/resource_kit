require 'spec_helper'

RSpec.describe ResourceKit::Testing::ActionHandlerMatchers do
  describe '#initialize' do
    it 'initializes with a resource class' do
      action = :all
      instance = described_class.new(action)
      expect(instance.action).to be(action)
    end
  end

  describe '#that_handles' do
    subject(:testing_matcher) { described_class.new(:all) }

    it 'returns itself' do
      expect(testing_matcher.that_handles(200)).to be(testing_matcher)
    end

    it 'accepts a status code' do
      testing_matcher.that_handles(200)
      expect(testing_matcher.handler_codes).to include(200)
    end

    it 'accepts a magic status code' do
      testing_matcher.that_handles(:ok)
      expect(testing_matcher.handler_codes).to include(200)
    end

    it 'accepts multiple status codes' do
      testing_matcher.that_handles(:ok, 201)
      expect(testing_matcher.handler_codes).to include(200, 201)
    end
  end

  describe '#at_path' do
    subject(:testing_matcher) { described_class.new(:all) }

    it 'sets the path we\'re specing' do
      testing_matcher.at_path('/hello')
      expect(testing_matcher.path).to eq('/hello')
    end
  end

  describe '#matches?' do
    subject(:testing_matcher) { described_class.new(:all) }

    context 'for a resource that has the defined action' do
      let(:resource_class) { Class.new(ResourceKit::Resource) }

      it 'matches with both code and path' do
        resource_class.resources do
          action :all, 'GET /hello' do
            handler(200) { }
          end
        end

        matcher = described_class.new(:all)
        matcher.that_handles(:ok).at_path('/hello')

        expect(matcher.matches?(resource_class)).to be_truthy
      end

      it 'matches with only code' do
        resource_class.resources do
          action :all, 'GET /hello' do
            handler(200) { }
          end
        end

        matcher = described_class.new(:all)
        matcher.that_handles(:ok)

        expect(matcher.matches?(resource_class)).to be_truthy
      end

      it 'matches with only path' do
        resource_class.resources { action :all, 'GET /hello' }

        matcher = described_class.new(:all)
        matcher.at_path('/hello')

        expect(matcher.matches?(resource_class)).to be_truthy
      end
    end
  end
end