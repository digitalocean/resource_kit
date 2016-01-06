module ResourceKit
  class ActionInvoker
    attr_reader :action, :connection, :args, :options, :resource

    def initialize(action, resource, *args)
      @action = action
      @resource = resource
      @connection = resource.connection
      @args = args
      @options = args.last.kind_of?(Hash) ? args.last : {}
    end

    def self.call(action, resource, *args)
      new(action, resource, *args).handle_response
    end

    def handle_response
      if handler = action.handlers[response.status] || action.handlers[:any]
        resource.instance_exec(response, *args, &handler) # Since the handler is a block, it does not enforce parameter length checking
      else
        response.body
      end
    end

    def construct_body
      action.body.call(*args[0..(action.body.arity - 1)])
    end

    def response
      return @response if @response

      raise ArgumentError, "Verb '#{action.verb}' is not allowed" unless ALLOWED_VERBS.include?(action.verb)

      @response = connection.send(action.verb, resolver.resolve(options)) do |request|
        request.body = construct_body if action.body and [:post, :put, :patch, :delete].include?(action.verb)
        append_hooks(:before, request)
      end
    end

    def resolver
      path = action.path.kind_of?(Proc) ? resource.instance_eval(&action.path) : action.path
      EndpointResolver.new(path: path, query_param_keys: action.query_keys)
    end

    private

    def append_hooks(hook_type, request)
      (action.hooks[hook_type] || []).each do |hook|
        case hook
        when Proc
          resource.instance_exec(*args, request, &hook)
        when Symbol
          resource.send(hook, *args, request)
        end
      end
    end
  end
end
