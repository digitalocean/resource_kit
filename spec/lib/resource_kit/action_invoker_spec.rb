require 'spec_helper'

RSpec.describe ResourceKit::ActionInvoker do
  let(:connection) { Faraday.new { |b| b.adapter :test, stubs } }
  let(:stubs) do
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/users') { |env| [200, {}, 'all users'] }
      stub.get('/users/bad_page') { |env| [404, {}, 'not found'] }
      stub.get('/users/12') { |env| [200, {}, 'user 12'] }
      stub.post('/users') { |env| [200, {}, env[:body]] }
      stub.get('/paged') { |env| [200, {}, env[:url].to_s] }
      stub.get('/before_hooks') { |env| [200, {}, env[:request_headers]['Owner-Id']] }
      stub.get('/block_based') { |env| [200, {}, 'block based path'] }
    end
  end
  let(:action) { ResourceKit::Action.new(:find) }
  let(:resource) { double('resource instance', connection: connection) }

  describe '.call' do
    it 'performs a request to the specfied URL' do
      action.verb :get
      action.path '/users'

      result = ResourceKit::ActionInvoker.call(action, resource)

      expect(result).to eq('all users')
    end

    it 'performs a request to the correct url when using a block for path' do
      action.path { '/block_based' }
      result = ResourceKit::ActionInvoker.call(action, resource)

      expect(result).to eq('block based path')
    end

    it 'substitues params on call' do
      action.verb :get
      action.path '/users/:id'

      result = ResourceKit::ActionInvoker.call(action, resource, id: 12)
      expect(result).to eq('user 12')
    end

    context 'when an action has a handler' do
      it 'returns the handler block' do
        action.verb :get
        action.path '/users'
        action.handler(200) { |response| 'changed' }

        result = ResourceKit::ActionInvoker.call(action, resource)

        expect(result).to eq('changed')
      end

      it 'passes the initial object' do
        action.verb :get
        action.path '/users'
        action.handler(200) { |response, hash| hash }

        target_hash = Hash.new
        result = ResourceKit::ActionInvoker.call(action, resource, target_hash)

        expect(result).to be target_hash
      end

      it 'uses the correct handler on status codes' do
        action.verb :get
        action.path '/users/bad_page'
        action.handler(404) { |response| '404ed' }

        result = ResourceKit::ActionInvoker.call(action, resource)
        expect(result).to eq('404ed')
      end

      it 'uses a default handler if provided' do
        action.verb :get
        action.path '/users'
        action.handler { |response| 'Something unexpected happened.' }

        result = ResourceKit::ActionInvoker.call(action, resource)
        expect(result).to eq('Something unexpected happened.')
      end
    end

    context 'for requests with bodies' do
      it 'uses the body handler when present' do
        action.verb :post
        action.path '/users'
        action.body { |object| 'i am a banana' }

        result = ResourceKit::ActionInvoker.call(action, resource, 'echo me')
        expect(result).to eq('i am a banana')
      end

      it 'uses the body handler with multiple arity when present' do
        action.verb :post
        action.path '/users'
        action.body { |first, second| first + second }

        result = ResourceKit::ActionInvoker.call(action, resource, 'echo me', ' another')
        expect(result).to eq('echo me another')
      end
    end

    context 'for requests with query params' do
      it 'appends the query parameters to the endpoint' do
        action.query_keys :per_page, :page
        action.path '/paged'

        result = ResourceKit::ActionInvoker.call(action, resource, page: 3, per_page: 300)
        addressed = Addressable::URI.parse(result)

        expect(addressed.query_values).to include('per_page' => '300', 'page' => '3')
      end
    end

    context 'for actions that have before request hooks' do
      it 'calls the before request with the request object' do
        action.path '/before_hooks'
        action.verb :get
        action.before_request { |req| req.headers['Owner-Id'] = 'bojangles' }

        result = ResourceKit::ActionInvoker.call(action, resource)
        expect(result).to eq('bojangles')
      end

      it 'calls the before request with the request object and arguments' do
        action.path '/before_hooks'
        action.verb :get
        action.before_request { |one, two, req| req.headers['Owner-Id'] = "#{one} #{two}" }

        result = ResourceKit::ActionInvoker.call(action, resource, 'one', 'two')
        expect(result).to eq('one two')
      end

      context 'for passing a symbol' do
        it 'calls the method on the context of the action' do
          def resource.kickit(request)
            request.headers['Owner-Id'] = 'btabes'
          end

          action.path '/before_hooks'
          action.verb :get
          action.before_request(:kickit)

          invoker = ResourceKit::ActionInvoker.new(action, resource)

          expect(invoker.handle_response).to eq('btabes')
        end

        it 'calls the action with arguments passed' do
          def resource.kickit(one, two, request)
            request.headers['Owner-Id'] = "#{one} #{two}"
          end

          action.path '/before_hooks'
          action.verb :get
          action.before_request(:kickit)

          invoker = ResourceKit::ActionInvoker.new(action, resource, 'bobby', 'tables')

          expect(invoker.handle_response).to eq('bobby tables')
        end
      end
    end
  end
end
