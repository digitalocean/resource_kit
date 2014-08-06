module ResourceKit
  class Action
    attr_reader :name

    def initialize(name, verb = nil, path = nil)
      @name = name
      @verb = (verb && verb.downcase.to_sym) || :get
      @path = path
      @query_keys = []
    end

    def verb(v = nil)
      @verb = v if v
      @verb
    end

    def path(path = nil)
      @path = path if path
      @path
    end

    def query_keys(*keys)
      return @query_keys if keys.empty?
      @query_keys += keys
    end

    def handlers
      @handlers ||= {}
    end

    def handler(*response_codes, &block)
      response_codes.each do |code|
        unless code.is_a?(Fixnum)
          code = StatusCodeMapper.code_for(code)
        end
        handlers[code] = block
      end
    end

    def body(&block)
      @body_handler = block if block_given?
      @body_handler
    end
  end
end