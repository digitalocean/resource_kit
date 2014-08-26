module ResourceKit
  class Resource
    class_attribute :_resources

    attr_reader :connection

    def initialize(connection)
      @connection = connection
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
  end
end