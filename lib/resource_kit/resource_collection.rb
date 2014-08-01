module ResourceKit
  class ResourceCollection
    extend Forwardable
    def_delegators :@collection, :find, :<<, :each, :include?

    def initialize
      @collection = []
    end

    def action(name, &block)
      action = Action.new(name)
      action.instance_eval(&block) if block_given?
      action.tap {|a| self << a }
    end

    def find_action(name)
      find do |action|
        action.name == name
      end
    end
  end
end