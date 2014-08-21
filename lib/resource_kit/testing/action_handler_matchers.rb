module ResourceKit
  module Testing
    class ActionHandlerMatchers
      attr_reader :action, :path

      def initialize(action)
        @action = action
      end

      def that_handles(*codes)
        codes.each do |code|
          handler_codes << StatusCodeMapper.code_for(code)
        end

        self
      end

      def at_path(path)
        @path = path
        self
      end

      def matches?(subject)
        action = subject.resources.find_action(self.action)
        return false unless action
        keys = action.handlers.keys

        if !keys.empty? && !handler_codes.empty?
          handler_codes.each do |handler_code|
            return false unless keys.include?(handler_code)
          end
        end

        return false if self.path && action.path != self.path

        true
      end

      def handler_codes
        @handler_codes ||= []
      end
    end
  end
end