module ResourceKit
  module Testing
    class ActionHandlerMatchers
      attr_reader :action

      def initialize(action)
        @action = action
      end

      def that_handles(*codes)
        codes.each do |code|
          handler_codes << StatusCodeMapper.code_for(code)
        end

        self
      end

      def handler_codes
        @handler_codes ||= []
      end
    end
  end
end