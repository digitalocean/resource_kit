module ResourceKit
  class ActionInvoker
    ALLOWED_VERBS = [:get, :post, :put, :delete, :head, :patch, :options]

    def self.call(action, connection, *args)
      raise ArgumentError, "Verb '#{action.verb}' is not allowed" unless action.verb.in?(ALLOWED_VERBS)
      options = args.extract_options!
      resolver = EndpointResolver.new(path: action.path)

      if args.size > 0 and action.verb.in?([:post, :put, :patch])
        # This request is going to have a response body. Handle it.
        response = connection.send(action.verb, resolver.resolve(options)) do |request|
          request.body = construct_body(args.first, action)
        end
      else
        response = connection.send(action.verb, resolver.resolve(options))
      end

      handle_response(response, action)
    end

    def self.handle_response(response, action)
      if handler = action.handlers[response.status]
        handler.call(response)
      else
        response.body
      end
    end

    def self.construct_body(object, action)
      if action.body
        action.body.call(object)
      else
        object.to_s
      end
    end
  end
end