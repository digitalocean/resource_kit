module ResourceKit
  module Testing
    class ActionHandlerMatchers
      ResponseStub = Class.new(OpenStruct)

      attr_reader :action, :response_stub

      def initialize(action)
        @action = action
      end

      def with(options, &block)
        @response_stub = ResponseStub.new(options)
        @handled_block = block

        self
      end

      def matches?(subject)
        action = subject.resources.find_action(self.action)
        return false unless action

        status_code = response_stub.status || 200
        return false unless action.handlers[status_code]

        handled_response = action.handlers[status_code].call(response_stub)
        @handled_block.call(handled_response)

        true
      end
    end
  end
end