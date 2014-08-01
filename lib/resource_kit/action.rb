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

    def handlers
      @handlers ||= {}
    end

    def handler(*response_codes, &block)
      response_codes.each {|code| handlers[code] = block }
    end

    def body(&block)
      @body_handler = block if block_given?
      @body_handler
    end
  end
end