require 'resource_kit/inheritable_attribute'

module ResourceKit
  class Resource
    extend InheritableAttribute
    inheritable_attr :_resources

    attr_reader :connection, :scope

    def initialize(connection: nil, scope: nil)
      @connection = connection
      @scope = scope
    end

    def self.resources(&block)
      self._resources ||= ResourceCollection.new

      if block_given?
        self._resources.instance_eval(&block)
        MethodFactory.construct(self, self._resources)
      end

      self._resources
    end

    def action(name)
      _resources.find_action(name)
    end

    def action_and_connection(action_name)
      ActionConnection.new(action(action_name), connection)
    end

    private

    def _resources
      self.class._resources
    end
  end
end
