require 'spec_helper'

describe ResourceKit::InheritableAttribute do
  subject do
    Class.new(Object) do
      extend ResourceKit::InheritableAttribute

      inheritable_attr :_resources
    end
  end

  it 'provides a reader with an empty inherited attribute' do
    expect(subject._resources).to be_nil
  end

  it 'provides a reader with empty inherited attributes in a derived class' do
    expect(Class.new(subject)._resources).to be_nil

    # subject._resouces = true
    # Class.new(subject)._resources # TODO: crashes.
  end

  it 'provides an attribute copy in subclasses' do
    subject._resources = []
    expect(subject._resources.object_id).not_to eq Class.new(subject)._resources.object_id
  end

  it 'provides a writer' do
    subject._resources = [:resource]
    expect(subject._resources).to eq [:resource]
  end

  it 'inherits attributes' do
    subject._resources = [:resource]

    subclass_a = Class.new(subject)
    subclass_a._resources << :another_resource

    subclass_b = Class.new(subject)
    subclass_b._resources << :different_resource

    expect(subject._resources).to eq [:resource]
    expect(subclass_a._resources).to eq [:resource, :another_resource]
    expect(subclass_b._resources).to eq [:resource, :different_resource]
  end

  it 'does not inherit attributes if we set explicitely' do
    subject._resources = [:resource]
    subclass = Class.new(subject)

    subclass._resources = [:another_resource]
    expect(subclass._resources).to eq [:another_resource]
  end
end
