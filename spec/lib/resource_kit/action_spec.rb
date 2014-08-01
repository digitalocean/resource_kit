require 'spec_helper'

RSpec.describe ResourceKit::Action do
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
end