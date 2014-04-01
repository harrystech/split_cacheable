# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
# require 'split_cacheable/version'

Gem::Specification.new do |spec|
  spec.name          = "split_cacheable"
  spec.version       = Split::Cacheable::VERSION
  spec.authors       = ["Daniel Schwartz"]
  spec.email         = ["dschwartz88@gmail.com"]
  spec.summary       = %q{A caching gem for Split}
  spec.description   = %q{A caching gem for Split}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "split"
  spec.add_dependency "pry"
  spec.add_dependency "pry-byebug"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
