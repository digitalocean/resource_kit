module ResourceKit
  module Testing
    class HaveActionMatchers
      attr_reader :action, :path, :verb

      def initialize(action)
        @action = action
        @failures = []
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

      def failure_message
        return "expected class to have action #{action}." if failures.empty?

        failures.map do |validation, expected, got|
          "expected #{expected} #{validation}, got #{got} instead."
        end.join('\n')
      end

      private
      attr_reader :failures

      def check_keys(action)
        keys = action.handlers.keys

        unless handler_codes.empty?
          handler_codes.each do |handler_code|
            unless keys.include?(handler_code)
              return failed(:status_code, handler_code, keys)
            end
          end
        end

        true
      end

      def check_path(action)
        return true unless self.path
        action.path == self.path or failed(:path, self.path, action.path)
      end

      def check_verb(action)
        return true unless self.verb
        checked_verb = self.verb.kind_of?(String) ? self.verb.downcase.to_sym : self.verb
        action.verb == checked_verb or failed(:verb, checked_verb, action.verb)
      end

      def failed(validation, expected, got)
        failures << [validation, expected, got]
        false
      end
    end
  end
end
