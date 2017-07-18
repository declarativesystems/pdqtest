[![Build Status](https://travis-ci.org/declarativesystems/pdqtest.svg?branch=master)](https://travis-ci.org/declarativesystems/pdqtest)

# PDQTest

PDQTest - Puppet Docker Quick-test - is the quickest and easiest way to test your puppet modules. PDQTest features tests for:
* Linting
* Syntax
* RSpec
* Acceptance ([BATS](https://github.com/sstephenson/bats))

And can generate code to retrofit testing to a new or existing module, along with skeleton RSpec and acceptance tests to get you started.

PDQTest runs linting, syntax and RSpec tests within the machine it is running from and then loads a docker container to perform acceptance testing, sharing the puppet module and cached dependencies from your host.

![demo](doc/demo.gif)
_Adding PDQTest to a project and running acceptance tests in Docker_

## PDQTest Manual
1. [Installation](doc/installation.md)
2. [Enabling testing](doc/enabling_testing.md)
3. [Running tests](doc/running_tests.md)
4. [Test generation](doc/test_generation.md)
5. [Puppet module dependencies](doc/puppet_module_dependencies.md)
6. [Puppet facts](doc/puppet_facts.md)
7. [Hiera](doc/hiera.md)
8. [Caching](doc/caching.md)
9. [Upgrading](doc/upgrading.md)
10. [Examples](doc/examples.md)
11. [Tips and tricks](doc/tips_and_tricks.md)
12. [Troubleshooting](doc/troubleshooting.md)
13. [Development](doc/development.md)
