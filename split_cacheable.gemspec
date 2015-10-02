# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'split_cacheable/version'

Gem::Specification.new do |spec|
  spec.name          = "split_cacheable"
  spec.version       = Split::Cacheable::VERSION
  spec.authors       = ["Daniel Schwartz"]
  spec.email         = ["dschwartz88@gmail.com"]
  spec.summary       = %q{We use action caching in Rails to cache both our standard and mobile site. We wanted to be able to quickly run Split tests without worrying about setting a custom cache_path each time as well as remembering to make the needed changes to our ActiveRecord models.}
  spec.description   = %q{An extension to Split to allow for automatic cache bucket creation accross Split tests.}
  spec.homepage      = "https://github.com/harrystech/split_cacheable"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "split", "~> 1.0.0"
  spec.add_dependency "activesupport", ">= 4.0"
  spec.add_dependency "actionpack-action_caching"

  spec.add_development_dependency "rspec", ">= 2.14"
  spec.add_development_dependency "pry", ">= 0"
  spec.add_development_dependency "pry-byebug", ">= 0"
  spec.add_development_dependency "mock_redis", ">=0.11.0"
end
