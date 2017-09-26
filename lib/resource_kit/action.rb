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

    def path(path = nil, &block)
      raise "You must pass either a block or a string for paths" if path and block_given?
      @path = path if path
      @path = block if block_given?
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
      if response_codes.empty?
        handlers[:any] = block
      else
        response_codes.each do |code|
          code = StatusCodeMapper.code_for(code) unless code.is_a?(Integer)
          handlers[code] = block
        end
      end
    end

    def body(&block)
      @body_handler = block if block_given?
      @body_handler
    end

    def hooks
      @hooks ||= {}
    end

    def before_request(method_name = nil, &block)
      hooks[:before] ||= []

      if block_given?
        hooks[:before] << block
      else
        raise "Must include a method name" unless method_name
        hooks[:before] << method_name
      end

      nil
    end
  end
end
