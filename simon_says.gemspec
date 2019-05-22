# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simon_says/version'

Gem::Specification.new do |spec|
  spec.name          = "simon_says"
  spec.version       = SimonSays::VERSION
  spec.authors       = ["Michael Coyne", "Cameron Craig", "SimplyBuilt"]
  spec.email         = ["mikeycgto@gmail.com"]
  spec.summary       = %q{Light-weight, declarative authorization and access control for Rails}
  spec.description   = %q{This gem is a simple, easy-to-use declarative role-based access control system for Rails}
  spec.homepage      = "https://github.com/SimplyBuilt/SimonSays"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 4.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rails", ">= 4.0", "< 5.2"
  spec.add_development_dependency "responders", "~> 2.0"
  spec.add_development_dependency "mocha", "~> 1.1"
end
