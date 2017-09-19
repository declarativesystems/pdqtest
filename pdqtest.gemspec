# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pdqtest/version'

Gem::Specification.new do |spec|
  spec.name          = "pdqtest"
  spec.version       = PDQTest::VERSION
  spec.authors       = ["Geoff Williams"]
  spec.email         = ["geoff.williams@puppetlabs.com"]

  spec.summary       = %q{Quick and simple integration tests run inside of a docker container}
  spec.description   = %q{write one...}
  spec.homepage      = "https://github.com/GeoffWilliams/pdqtest"
  spec.licenses      = 'Apache-2.0'

  # file MUST be in git to be fucking readable!!!!!
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "coveralls", "0.8.21"
  spec.add_development_dependency "fakefs", "0.11.0"
  spec.add_development_dependency "puppet", "4.10.8"

  spec.add_runtime_dependency "rake", "12.0.0"
  spec.add_runtime_dependency "rspec", "3.5.0"
  spec.add_runtime_dependency "thor", "0.19.4"
  spec.add_runtime_dependency "minitar", "0.6.1"
  spec.add_runtime_dependency "hiera", "3.4.0"
  spec.add_runtime_dependency "escort", "0.4.0"
  spec.add_runtime_dependency "docker-api", "1.33.1"
  spec.add_runtime_dependency "puppet-lint", "2.1.0"
  spec.add_runtime_dependency "puppet-syntax", "2.2.0"
  spec.add_runtime_dependency "puppetlabs_spec_helper", "1.2.2"
  spec.add_runtime_dependency "librarian-puppet", "2.2.3"
  spec.add_runtime_dependency "git_refresh", "0.1.1"
  spec.add_runtime_dependency "puppet_factset", "0.5.0"
end
