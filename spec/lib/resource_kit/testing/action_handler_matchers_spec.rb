require 'spec_helper'
require 'json'

RSpec.describe ResourceKit::Testing::ActionHandlerMatchers do
  let(:resource_class) { Class.new(ResourceKit::Resource) }
  subject(:matcher) { described_class.new(:all) }

  describe '#initialize' do
    it 'initializes with a resource class' do
      action = :all
      instance = described_class.new(action)
      expect(instance.action).to be(action)
    end
  end

  describe '#with' do
    it 'sets the passed response params' do
      matcher.with(status: 200, body: 'Hello World')
      expect(matcher.response_stub.status).to eq(200)
      expect(matcher.response_stub.body).to eq('Hello World')
    end
  end

  describe '#matches?' do
    it 'matches when the resource handles the block correctly' do
      resource_class.resources.action :all, 'GET /all' do
        handler(200) { |response| JSON.load(response.body) }
      end

      change_var = nil
      matcher.with(status: 200, body: '{"hello": "world"}') do |handled|
        expect(handled['hello']).to eq('world')
        change_var = true
      end

      expect(matcher.matches?(resource_class)).to be_truthy
      expect(change_var).to be(true)
    end
  end

  describe '#failure_message' do
    context "when the matchers doesnt handle the same status code" do
      it 'returns "expected the #{status_code} status code to be handled by the class."' do
        resource_class.resources.action :all, 'GET /all' do
          handler(200) { |response| JSON.load(response.body) }
        end

        matcher.with(status: 201, body: '{"Hello": "World"}')
        matcher.matches?(resource_class) { }

        expect(matcher.failure_message).to eq('expected the 201 status code to be handled by the class.')
      end
    end

    context "when the matchers doesnt handle the same status code" do
      it 'returns "expected the #{status_code} status code to be handled by the class."' do
        resource_class.resources.action :show, 'GET /all' do
          handler(200) { |response| JSON.load(response.body) }
        end

        matcher.with(status: 200, body: '{"Hello": "World"}')
        matcher.matches?(resource_class) { }

        expect(matcher.failure_message).to eq('expected :all to be handled by the class.')
      end
    end
  end
end
