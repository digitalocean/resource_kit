require 'resource_kit/version'

module ResourceKit
  ALLOWED_VERBS = [:get, :post, :put, :delete, :head, :patch, :options]
  ActionConnection = Struct.new(:action, :connection)

  autoload :Resource, 'resource_kit/resource'
  autoload :ResourceCollection, 'resource_kit/resource_collection'

  autoload :Action, 'resource_kit/action'
  autoload :ActionInvoker, 'resource_kit/action_invoker'
  autoload :MethodFactory, 'resource_kit/method_factory'

  autoload :StatusCodeMapper, 'resource_kit/status_code_mapper'
  autoload :EndpointResolver, 'resource_kit/endpoint_resolver'

end
