module ResourceKit
  class ActionInvoker
    attr_reader :action, :connection, :args, :options

    attr_accessor :context

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
        context.instance_exec(response, &handler)
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

      @response = connection.send(action.verb, resolver.resolve(options)) do |request|
        request.body = construct_body if action.body and action.verb.in?([:post, :put, :patch])
        append_hooks(:before, request)
      end
    end

    def resolver
      EndpointResolver.new(path: action.path, query_param_keys: action.query_keys)
    end

    private

    def append_hooks(hook_type, request)
      (action.hooks[hook_type] || []).each do |hook|
        context.instance_exec(*args, request, &hook) and next if hook.kind_of?(Proc)
        context.send(hook, *args, request)
      end
    end
  end
end