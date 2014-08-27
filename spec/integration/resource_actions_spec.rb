require 'spec_helper'

class DummyResourceActions < ResourceKit::Resource
  resources do
    action :dummy, 'GET /dummy' do
      handler(200) { |resp| resp.body.upcase }
    end

    action :headered, 'GET /headered' do
      before_request { |req| req.headers['Added-Header'] = self.value }
    end
  end

  def value
    scope.value
  end
end

RSpec.describe 'Resource Actions' do
  let(:connection) { Faraday.new { |b| b.adapter :test, stubs } }
  let(:scoped) { double('scope', value: 'bunk') }
  let(:stubs) do
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/dummy') { |env| [200, {}, 'dummies'] }
      stub.get('/headered') { |env| [200, {}, env[:request_headers]['Added-Header']] }
    end
  end

  it 'Retrieving /dummy returns the body as uppercased' do
    resource = DummyResourceActions.new(connection: connection, scope: scoped)
    response = resource.dummy
    expect(response).to eq('DUMMIES')
  end

  it 'adds the header before the request happens' do
    resource = DummyResourceActions.new(connection: connection, scope: scoped)
    response = resource.headered

    expect(response).to eq(scoped.value)
  end
end