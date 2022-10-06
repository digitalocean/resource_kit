require 'spec_helper'

RSpec.describe ResourceKit::SingletonRequests do
  let(:klass) do
    Class.new(ResourceKit::Resource) do
      include ResourceKit::SingletonRequests

      resources do
        get '/hello' => :hello
      end
    end
  end

  describe 'Inclusions' do
    let(:connection) { Faraday.new { |b| b.adapter :test, stubs } }
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/hello') { |env| [200, {}, 'world'] }
      end
    end

    before do
      # Set the default connection for the resource to our stubbed one
      klass.resources.default_connection { connection }
    end

    it 'allows calling actions as class methods' do
      value = klass.hello
      expect(value).to eq('world')
    end

    it 'defines the method on the class when called' do
      expect { klass.hello }.to change { klass.methods.include?(:hello) }.to(true).from(false)
    end
  end
end