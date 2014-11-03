module ResourceKit
  module SingletonRequests
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def method_missing(action_name, *args, &block)
        if action = resources.find_action(action_name)
          define_method_for_action(action_name)
          send(action_name, *args, &block)
        else
          super
        end
      end

      private

      def define_method_for_action(action_name)
        class_eval <<-RUBY
          def self.#{action_name}(*args, &block)
            resource_instance = new
            resource_instance.send(:#{action_name}, *args, &block)
          end
        RUBY
      end
    end
  end
end