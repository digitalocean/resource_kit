require 'spec_helper'

RSpec.describe ResourceKit::EndpointResolver do
  describe '#initialize' do
    it 'initializes with pieces of a URL' do
      options = { path: '/users', namespace: '/v2', query_param_keys: ['per_page', 'page'] }
      instance = ResourceKit::EndpointResolver.new(options)

      expect(instance.path).to eq(options[:path])
      expect(instance.query_param_keys).to eq(options[:query_param_keys])
    end
  end

  describe '#resolve' do
    let(:path) { '/users' }
    let(:query_param_keys) { [] }
    let(:options) { { path: path, query_param_keys: query_param_keys } }

    subject(:resolver) { ResourceKit::EndpointResolver.new(options) }

    context 'simple resolve' do
      it 'creates a populated URL from passed values' do
        endpoint = resolver.resolve()
        expect(endpoint).to eq('/users')
      end
    end

    context 'substituted paths' do
      let(:path) { '/users/:id' }

      it 'creates a populated URL from passed values' do
        endpoint = resolver.resolve(id: 1066)
        expect(endpoint).to eq('/users/1066')
      end
    end

    context 'with query parameters' do
      let(:query_param_keys) { [:per_page, :page] }

      it 'generates a URL with query parameters set correctly' do
        endpoint = resolver.resolve(per_page: 2, page: 3)

        uri = Addressable::URI.parse(endpoint)
        expect(uri.query_values).to eq("per_page" => '2', "page" => '3')
      end
    end

    context 'with query parameters already appended' do
      let(:path) { '/:something/users?foo=bar' }
      let(:query_param_keys) { [:per_page, :page] }

      it 'appends the query params to the url that already has some' do
        endpoint = resolver.resolve(something: 'testing', per_page: 2, page: 3)

        uri = Addressable::URI.parse(endpoint)
        expect(uri.query_values).to eq("foo" => 'bar', "per_page" => '2', "page" => '3')
      end
    end
  end
end