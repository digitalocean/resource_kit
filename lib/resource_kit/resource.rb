module ResourceKit
  class Resource
    class_attribute :namespace

    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def self.resources(&block)
      @resources ||= ResourceCollection.new
      @resources.instance_eval(&block) if block_given?

      MethodFactory.construct(self, @resources)
      @resources
    end
  end
end