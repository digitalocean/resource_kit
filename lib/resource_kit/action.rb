module ResourceKit
  class Action
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end
end