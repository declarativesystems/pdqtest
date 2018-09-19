# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pdqtest/version'

Gem::Specification.new do |spec|
  spec.name          = "pdqtest"
  spec.version       = PDQTest::VERSION
  spec.authors       = ["Geoff Williams"]
  spec.email         = ["geoff@declarativesystems.com"]

  spec.summary       = %q{Quick and simple integration tests run inside of a docker container}
  spec.homepage      = "https://github.com/DeclarativeSystems/pdqtest"
  spec.licenses      = 'Apache-2.0'

  # file MUST be in git to be fucking readable!!!!!
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "coveralls", "0.8.21"
  spec.add_development_dependency "fakefs", "0.14.2"
  spec.add_development_dependency "puppet", "5.3.5"
  spec.add_development_dependency "rspec", "3.7.0"

  spec.add_runtime_dependency "rake", "12.3.1"
  spec.add_runtime_dependency "thor", "~> 0.19"
  spec.add_runtime_dependency "minitar", "0.6.1"
  spec.add_runtime_dependency "escort", "0.4.0"
  spec.add_runtime_dependency "docker-api", "1.34.2"
  spec.add_runtime_dependency "r10k", "2.6.4"
  spec.add_runtime_dependency "git_refresh", "0.1.1"
  spec.add_runtime_dependency "logging", "~> 2.2"
  spec.add_runtime_dependency 'deep_merge', '~> 1.2'
end
