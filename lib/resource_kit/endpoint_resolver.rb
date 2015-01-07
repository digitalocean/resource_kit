require 'addressable/uri'

module ResourceKit
  class EndpointResolver
    attr_reader :path, :query_param_keys

    def initialize(options = {})
      @path = options[:path]
      @query_param_keys = options[:query_param_keys] || []
    end

    def resolve(values = {})
      uri = Addressable::URI.parse(path)
      new_path = generated_path(uri.path, values)

      uri.path = normalized_path_components(new_path)
      uri.query = append_query_values(uri, values) unless query_param_keys.empty?

      uri.to_s
    end

    private

    def generated_path(supplied_path, values)
      values.inject(supplied_path) do |np, (key, value)|
        np.gsub(":#{key}", value.to_s)
      end
    end

    def normalized_path_components(*components)
      components.reject(&:empty?).map do |piece|
        # Remove leading and trailing forward slashes
        piece.gsub(/(^\/)|(\/$)/, '')
      end.join('/').insert(0, '/')
    end

    def append_query_values(uri, values)
      pre_vals = uri.query_values || {}
      params = query_param_keys.each_with_object(pre_vals) do |key, query_values|
        query_values[key] = values[key] if values.has_key?(key)
      end

      URI.encode_www_form(params)
    end
  end
end
