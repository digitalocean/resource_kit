require 'spec_helper'

class DummyInheritenceResource < ResourceKit::Resource
  resources do
    default_handler(:ok) { |resp| "Hello" }
    get "/dummy" => :dummy
  end
end

class DummyChildResource < DummyInheritenceResource
  resources do
    get "/inherited" => :inherited
  end
end

RSpec.describe 'Resource Inheritence' do
  it 'inherits the superclasses actions' do
    action = DummyChildResource.resources.find_action(:dummy)
    expect(action).to_not be_nil
    expect(action.name).to eq(:dummy)
  end

  it 'inherits default handlers' do
    expect(DummyChildResource.resources.default_handlers[200]).to_not be_nil
  end

  it 'does not modify the parent resource class' do
    expect(DummyInheritenceResource.resources.find_action(:inherited)).to be_nil
  end
end