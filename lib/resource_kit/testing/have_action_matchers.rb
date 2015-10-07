module ResourceKit
  module Testing
    class HaveActionMatchers
      attr_reader :action, :path, :verb

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

      def with_verb(verb)
        @verb = verb
        self
      end

      def matches?(subject)
        action = subject.resources.find_action(self.action)
        return false unless action

        %i(check_keys check_path check_verb).inject(true) do |rv, method_name|
          break false unless send(method_name, action)
          true
        end
      end

      def handler_codes
        @handler_codes ||= []
      end

      private

      def check_keys(action)
        keys = action.handlers.keys

        unless handler_codes.empty?
          handler_codes.each do |handler_code|
            return false unless keys.include?(handler_code)
          end
        end

        true
      end

      def check_path(action)
        return true unless self.path
        action.path == self.path
      end

      def check_verb(action)
        return true unless self.verb
        checked_verb = self.verb.kind_of?(String) ? self.verb.downcase.to_sym : self.verb
        action.verb == checked_verb
      end
    end
  end
end