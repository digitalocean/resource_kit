module ResourceKit
  class MethodFactory
    def self.construct(object, resource_collection, invoker = ActionInvoker)
      resource_collection.each do |action|
        if object.method_defined?(action.name)
          raise ArgumentError, "Action '#{action.name}' is already defined on `#{object}`"
        end
        method_block = method_for_action(action, invoker)

        object.send(:define_method, action.name, &method_block)
      end
    end

    def self.method_for_action(action, invoker)
      Proc.new do |*args|
        invoker.call(action, self, *args)
      end
    end
  end
end