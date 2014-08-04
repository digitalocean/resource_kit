require 'spec_helper'

RSpec.describe ResourceKit::ActionInvoker do
  let(:connection) { Faraday.new {|b| b.adapter :test, stubs } }
  let(:stubs) do
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/users') { |env| [200, {}, 'all users'] }
      stub.get('/users/bad_page') { |env| [404, {}, 'not found'] }
      stub.get('/users/12') { |env| [200, {}, 'user 12'] }
      stub.post('/users') { |env| [200, {}, env[:body]] }
    end
  end
  let(:action) { ResourceKit::Action.new(:find) }

  describe '.call' do
    it 'performs a request to the specfied URL' do
      action.verb :get
      action.path '/users'

      result = ResourceKit::ActionInvoker.call(action, connection)

      expect(result).to eq('all users')
    end

    it 'substitues params on call' do
      action.verb :get
      action.path '/users/:id'

      result = ResourceKit::ActionInvoker.call(action, connection, id: 12)
      expect(result).to eq('user 12')
    end

    context 'when an action has a handler' do
      it 'returns the handler block' do
        action.verb :get
        action.path '/users'
        action.handler(200) {|response| 'changed' }

        result = ResourceKit::ActionInvoker.call(action, connection)

        expect(result).to eq('changed')
      end

      it 'uses the correct handler on status codes' do
        action.verb :get
        action.path '/users/bad_page'
        action.handler(404) {|response| '404ed' }

        result = ResourceKit::ActionInvoker.call(action, connection)
        expect(result).to eq('404ed')
      end
    end

    context 'for requests with bodies' do
      it 'includes the contents of the body in the request' do
        action.verb :post
        action.path '/users'
        action.body {|str| str }

        result = ResourceKit::ActionInvoker.call(action, connection, 'echo me')
        expect(result).to eq('echo me')
      end

      it 'uses the body handler when present' do
        action.verb :post
        action.path '/users'
        action.body {|object| 'i am a banana' }

        result = ResourceKit::ActionInvoker.call(action, connection, 'echo me')
        expect(result).to eq('i am a banana')
      end
    end
  end
end