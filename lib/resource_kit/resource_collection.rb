module ResourceKit
  class ResourceCollection
    extend Forwardable
    def_delegators :@collection, :find, :<<, :each, :include?

    def initialize
      @collection = []
    end

    def action(name, verb_and_path = nil, &block)
      action = Action.new(name, *parse_verb_and_path(verb_and_path))
      action.handlers.merge!(default_handlers.dup)
      action.instance_eval(&block) if block_given?
      action.tap { |a| self << a }
    end

    ResourceKit::ALLOWED_VERBS.each do |verb|
      define_method verb do |path_name, &block|
        path, name = path_name.to_a.flatten
        action(name, "#{verb.upcase} #{path}", &block)
      end
    end

    def default_handler(*response_codes, &block)
      if response_codes.empty?
        default_handlers[:any] = block
      else
        response_codes.each do |code|
          code = StatusCodeMapper.code_for(code) unless code.is_a?(Integer)
          default_handlers[code] = block
        end
      end
    end

    def default_handlers
      @default_handlers ||= {}
    end

    def find_action(name)
      find do |action|
        action.name == name
      end
    end

    private

    def parse_verb_and_path(verb_and_path)
      return [] unless verb_and_path
      regex = /(?<verb>GET|POST|HEAD|PUT|PATCH|DELETE|OPTIONS)?\s*(?<path>.+)?/i
      matched = verb_and_path.match(regex)

      return matched[:verb], matched[:path]
    end
  end
end
