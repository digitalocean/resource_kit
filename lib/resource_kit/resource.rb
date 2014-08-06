module ResourceKit
  class Resource
    class_attribute :_resources

    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def self.resources(&block)
      self._resources ||= ResourceCollection.new
      self._resources.instance_eval(&block) if block_given?

      MethodFactory.construct(self, self._resources)
      self._resources
    end

    def action(name)
      _resources.find_action(name)
    end

    def action_and_connection(action_name)
      ActionConnection.new(action(action_name), connection)
    end
  end
end