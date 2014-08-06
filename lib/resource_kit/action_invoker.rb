module ResourceKit
  class ActionInvoker
    attr_reader :action, :connection, :args, :options

    def initialize(action, connection, *args)
      @action = action
      @connection = connection
      @args = args
      @options = args.last.kind_of?(Hash) ? args.last : {}
    end

    def self.call(action, connection, *args)
      new(action, connection, *args).handle_response
    end

    def handle_response
      if handler = action.handlers[response.status]
        handler.call(response)
      else
        response.body
      end
    end

    def construct_body
      action.body.call(*args[0..(action.body.arity - 1)])
    end

    def response
      return @response if @response

      raise ArgumentError, "Verb '#{action.verb}' is not allowed" unless action.verb.in?(ALLOWED_VERBS)

      if action.body and action.verb.in?([:post, :put, :patch])
        # This request is going to have a response body. Handle it.
        @response = connection.send(action.verb, resolver.resolve(options)) do |request|
          request.body = construct_body
        end
      else
        @response = connection.send(action.verb, resolver.resolve(options))
      end
    end

    def resolver
      EndpointResolver.new(path: action.path, query_param_keys: action.query_keys)
    end
  end
end