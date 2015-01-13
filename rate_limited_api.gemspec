# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rate_limited_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'rate_limited_api'
  spec.version       = RateLimitedApi::VERSION
  spec.authors       = ["Yann Marquet"]
  spec.email         = ["ymarquet@gmail.com"]
  spec.description   = %q{limit, throttle and delay code exection}
  spec.summary       = %q{limit, throttle and delay code exection}
  spec.homepage      = 'https://github.com/StupidCodeFactory/rate_limited_api'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activejob'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'redis'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency "byebug"
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'mimic'
  spec.add_development_dependency 'rack-throttle'
end
