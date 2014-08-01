module ResourceKit
  class ResourceCollection
    extend Forwardable
    def_delegators :@collection, *(Array.instance_methods - Object.instance_methods)

    def initialize
      @collection = []
    end

    def action(name, &block)
      action = Action.new(name)
      action.instance_eval(&block) if block_given?
      action.tap {|a| self << a }
    end

    def find_action(name)
      select do |action|
        action.name == name
      end[0]
    end
  end
end