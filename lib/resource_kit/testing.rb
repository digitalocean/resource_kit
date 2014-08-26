require 'resource_kit/testing/have_action_matchers'
require 'resource_kit/testing/action_handler_matchers'

module ResourceKit
  module Testing
    def have_action(action)
      HaveActionMatchers.new(action)
    end

    def handle_response(action, &block)
      ActionHandlerMatchers.new(action)
    end
  end
end

if defined?(RSpec)
  RSpec.configure do |config|
    config.include ResourceKit::Testing, resource_kit: true
  end
end