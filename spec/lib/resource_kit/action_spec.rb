require 'spec_helper'

RSpec.describe ResourceKit::Action do
  describe '#initialize' do
    it 'initializes with a name' do
      instance = ResourceKit::Action.new(:all)
      expect(instance.name).to eq(:all)
    end
  end
end