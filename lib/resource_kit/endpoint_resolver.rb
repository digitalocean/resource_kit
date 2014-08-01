require 'addressable/uri'

module ResourceKit
  class EndpointResolver
    attr_reader :host, :path, :namespace, :query_param_keys, :extension

    def initialize(options = {})
      @host = options[:host]
      @path = options[:path]
      @namespace = options[:namespace]
      @query_param_keys = options[:query_param_keys] || {}
    end

    def resolve(values = {})
      uri = Addressable::URI.parse(host)
      new_path = generated_path(values)
      uri.path = normalized_path_components(namespace, new_path)
      uri.query = append_query_values(uri, values) unless query_param_keys.empty?

      uri.to_s
    end

    private

    def generated_path(values)
      values.inject(path) do |np, (key, value)|
        np.gsub(":#{key}", value.to_s)
      end
    end

    def normalized_path_components(*components)
      components.reject(&:blank?).map do |piece|
        # Remove leading and trailing forward slashes
        piece.gsub(/(^\/)|(\/$)/, '')
      end.join('/')
    end

    def append_query_values(uri, values)
      query_param_keys.each_with_object({}) do |key, query_values|
        query_values[key] = values[key] if values.has_key?(key)
      end.to_query
    end
  end
end