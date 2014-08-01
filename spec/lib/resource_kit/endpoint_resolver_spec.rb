require 'spec_helper'

RSpec.describe ResourceKit::EndpointResolver do
  describe '#initialize' do
    it 'initializes with pieces of a URL' do
      options = { host: 'http://api.something.com', path: '/users', namespace: '/v2', query_param_keys: ['per_page', 'page'] }
      instance = ResourceKit::EndpointResolver.new(options)

      expect(instance.host).to eq(options[:host])
      expect(instance.path).to eq(options[:path])
      expect(instance.namespace).to eq(options[:namespace])
      expect(instance.query_param_keys).to eq(options[:query_param_keys])
    end
  end

  describe '#resolve' do
    let(:options) { { host: 'http://api.something.com', path: '/users' } }
    subject(:resolver) { ResourceKit::EndpointResolver.new(options) }

    context 'simple resolve' do
      it 'creates a populated URL from passed values' do
        endpoint = resolver.resolve()
        expect(endpoint).to eq('http://api.something.com/users')
      end
    end

    context 'substituted paths' do
      let(:options) { super().merge(path: '/users/:id') }

      it 'creates a populated URL from passed values' do
        endpoint = resolver.resolve(id: 1066)
        expect(endpoint).to eq('http://api.something.com/users/1066')
      end
    end

    context 'with a namespace' do
      let(:options) { super().merge(path: 'users/:id', namespace: '/v2/') }

      it 'creates a populated URL from passed values' do
        endpoint = resolver.resolve(id: 1066)
      end

      it 'handles multiple passed values' do
        options[:path] = 'users/:user_id/comments/:id.json'
        endpoint = resolver.resolve(user_id: 1066, id: 1337)
        expect(endpoint).to eq('http://api.something.com/v2/users/1066/comments/1337.json')
      end
    end

    context 'with query parameters' do
      let(:options) { super().merge(path: '/users', query_param_keys: [:per_page, :page]) }

      it 'generates a URL with query parameters set correctly' do
        endpoint = resolver.resolve(per_page: 2, page: 3)

        uri = Addressable::URI.parse(endpoint)
        expect(uri.query_values).to eq("per_page" => '2', "page" => '3')
      end
    end
  end
end