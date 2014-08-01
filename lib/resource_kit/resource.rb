module ResourceKit
  class Resource
    def self.resources(&block)
      @resources ||= ResourceCollection.new
      @resources.instance_eval(&block) if block_given?

      MethodFactory.construct(self, @resources)
      @resources
    end
  end
end