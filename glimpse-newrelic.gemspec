# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'glimpse/newrelic/version'

Gem::Specification.new do |spec|
  spec.name          = "glimpse-newrelic"
  spec.version       = Glimpse::NewRelic::VERSION
  spec.authors       = ["Jason R. Clark", "Ben Weintraub"]
  spec.email         = ["jclark@newrelic.com", "ben@newrelic.com"]
  spec.description   = %q{Glimpse plugin for displaying New Relic information client-side}
  spec.summary       = %q{Glimpse plugin for displaying New Relic information client-side}
  spec.homepage      = "http://github.com/jasonrclark/Glimpse.NewRelic"
  spec.license       = "Apache"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
