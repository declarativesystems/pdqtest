# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'quicktest/version'

Gem::Specification.new do |spec|
  spec.name          = "quicktest"
  spec.version       = Quicktest::VERSION
  spec.authors       = ["Geoff Williams"]
  spec.email         = ["geoff.williams@puppetlabs.com"]

  spec.summary       = %q{Quick and simple integration tests run inside of a docker container}
  spec.description   = %q{write one...}
  spec.homepage      = "https://github.com/GeoffWilliams/quicktest"
  spec.licenses      = 'apache-2'

  # file MUST be in git to be fucking readable!!!!!
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "0.12.0"
  spec.add_development_dependency "fakefs", "0.10.1"

  spec.add_runtime_dependency "escort", "0.4.0"
  spec.add_runtime_dependency "docker-api"
end
