# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resource_kit/version'

Gem::Specification.new do |spec|
  spec.name          = "resource_kit"
  spec.version       = ResourceKit::VERSION
  spec.authors       = ["Robert Ross", "Ivan Vanderbyl"]
  spec.email         = ["engineering@digitalocean.com", "rross@digitalocean.com", "ivan@digitalocean.com"]
  spec.summary       = %q{Resource Kit provides tools to aid in making API Clients. Such as URL resolving, Request / Response layer, and more.}
  spec.description   = ''
  spec.homepage      = "https://github.com/digitaloceancloud/resource_kit"
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'addressable', '< 3.0.0', '>= 2.3.6'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'faraday'
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 1.18.0"
  spec.add_development_dependency "kartograph", "~> 0.0.8"
  spec.add_development_dependency "pry", "~> 0.10.1"
end
