require "resource_kit/version"
require 'active_support/core_ext'

module ResourceKit
  autoload :Resource, 'resource_kit/resource'
  autoload :ResourceCollection, 'resource_kit/resource_collection'

  autoload :Action, 'resource_kit/action'
  autoload :MethodFactory, 'resource_kit/method_factory'

  autoload :StatusCodeMapper, 'resource_kit/status_code_mapper'
  autoload :EndpointResolver, 'resource_kit/endpoint_resolver'

end
