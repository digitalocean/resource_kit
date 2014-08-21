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
end

__END__

expect(MyResourceClass).to have_action(:all).that_handles(:ok, :no_content).at_path('/users')
