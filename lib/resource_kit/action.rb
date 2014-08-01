module ResourceKit
  class Action
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def verb(v = nil)
      @verb = v if v
      @verb
    end

    def path(path = nil)
      @path = path if path
      @path
    end
  end
end