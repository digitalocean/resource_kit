module ResourceKit
  class Resource
    def self.resources(&block)
      @resources ||= ResourceCollection.new
      @resources.instance_eval(&block) if block_given?
      @resources
    end
  end
end