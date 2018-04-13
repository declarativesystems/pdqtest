[![Build Status](https://travis-ci.org/declarativesystems/pdqtest.svg?branch=master)](https://travis-ci.org/declarativesystems/pdqtest)

# PDQTest

PDQTest - Puppet Docker Quick-test - is the quickest and easiest way to test your puppet modules. PDQTest features tests for:
* Linting
* Syntax
* RSpec
* Acceptance ([BATS-core](https://github.com/bats-core/bats-core))

And can generate code to retrofit testing to a new or existing module, along with skeleton RSpec and acceptance tests to get you started.

PDQTest runs linting, syntax and RSpec tests within the machine it is running from and then loads a docker container to perform acceptance testing, sharing the puppet module and cached dependencies from your host.

![demo](doc/demo.gif)
_Adding PDQTest to a project and running acceptance tests in Docker_

## PDQTest Manual
1. [Installation](doc/installation.md)
1. [Enabling testing](doc/enabling_testing.md)
1. [Running tests](doc/running_tests.md)
1. [Test generation](doc/test_generation.md)
1. [Acceptance tests](doc/acceptance_tests.md)
1. [Puppet module dependencies](doc/puppet_module_dependencies.md)
1. [Puppet facts](doc/puppet_facts.md)
1. [Hiera](doc/hiera.md)
1. [Caching](doc/caching.md)
1. [Upgrading](doc/upgrading.md)
1. [Emoji](doc/emoji.md)
1. [Examples](doc/examples.md)
1. [Tips and tricks](doc/tips_and_tricks.md)
1. [Troubleshooting](doc/troubleshooting.md)
1. [Development](doc/development.md)
