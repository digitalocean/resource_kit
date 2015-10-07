require 'ostruct'

module ResourceKit
  module Testing
    class ActionHandlerMatchers
      ResponseStub = Class.new(OpenStruct)

      attr_reader :action, :response_stub, :failure_message

      def initialize(action)
        @action = action
      end

      def with(options, &block)
        @response_stub = ResponseStub.new(options)
        @handled_block = block

        self
      end

      def matches?(subject, &block)
        @handled_block ||= block
        action = subject.resources.find_action(self.action)
        unless action
          @failure_message = "expected :#{self.action} to be handled by the class."
          return false
        end

        status_code = response_stub.status || 200
        unless action.handlers[status_code]
          @failure_message = "expected the #{status_code} status code to be handled by the class."
          return false
        end

        handled_response = action.handlers[status_code].call(response_stub)
        @handled_block.call(handled_response)

        true
      end
    end
  end
end
