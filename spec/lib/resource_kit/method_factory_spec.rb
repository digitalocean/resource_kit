require 'spec_helper'

RSpec.describe ResourceKit::MethodFactory do
  let(:collection) { ResourceKit::ResourceCollection.new }
  let(:klass) { Class.new { attr_accessor :connection } }

  describe '.construct' do
    before do
      collection.action :find
      collection.action :all
    end

    it 'adds the methods from the resource collection to the passed object' do
      ResourceKit::MethodFactory.construct(klass, collection)
      instance = klass.new
      expect(instance).to respond_to(:find, :all)
    end

    it 'adds the correct interface for the action' do
      ResourceKit::MethodFactory.construct(klass, collection)
      method_sig = klass.instance_method(:all).parameters

      expect(method_sig).to eq([[:rest, :args]])
    end

  end

  describe 'Calling the method' do
    it 'calls the invoker passed with the arguments and action' do
      action = ResourceKit::Action.new(:bunk)
      collection << action
      invoker = double('invoker', call: true)

      ResourceKit::MethodFactory.construct(klass, collection, invoker)

      instance = klass.new
      instance.connection = double('connection')
      instance.bunk('something', 'something else')
      expect(invoker).to have_received(:call).with(action, instance, 'something', 'something else')
    end
  end
end