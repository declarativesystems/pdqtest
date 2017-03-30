[![Build Status](https://travis-ci.org/declarativesystems/pdqtest.svg?branch=master)](https://travis-ci.org/GeoffWilliams/pdqtest)

# PDQTest

PDQTest - Puppet Docker Quick-test - is the quickest and easiest way to test your puppet modules. PDQTest features tests for:
* Linting
* Syntax
* RSpec
* Acceptance (BATS)

PDQTest runs linting, syntax and RSpec tests within the machine it is running from and then loads a docker container to perform acceptance testing.

## Installation

To install PDQTest on your system:

### System Ruby
```shell
gem install pdqtest
```

### Bundler, add this line to your application's Gemfile:
```ruby
gem 'pdqtest
```
* It's advisable to specify a version number to ensure repeatable builds

### Puppet modules
To add PDQTests to a puppet module, run the command:
```
pdqtest init
```

This will install PDQTest into the `Gemfile` and will generate an example set of acceptance tests

## Running tests

### Module dependencies/.fixtures.yml
Ordinarily, there is no need to maintain a `.fixtures.yml` file.  Dependencies on public forge modules should be specified in your module's `metadata.json` file.

If you need to download modules from git (eg those not available on forge.puppetlabs.com), then you must populate the `fixtures` section of `.fixtures.yml`, eg:

```
repositories:
  corporatestuff:
    repo: 'https://nonpublicgit.megacorp.com/corporatestuff.git'
    ref: 'mybranch'
```

Note that only the repositories section of the file will be processed as we do not use `puppetlabs_spec_helper` to do this for us.

### All tests
If you just want to run all tests:

```shell
bundle exec pdqtest all
```

### RSpec tests
```shell
bundle exec pdqtest rspec
```

### Debugging failed builds
PDQTest makes it easy to debug failed builds:

```shell
pdqtest shell
```

* Open a shell inside the docker container that would be used to run tests
* Your code is available at `/cut`

```shell
pdqtest --keep-container all
```
* Run all tests, report pass/fail status
* Keep the container Running
* After testing, the container used to run tests will be left running and a message will be printed showing how to enter the container used for testing.  Your code is avaiable at `/cut`

## Development

PRs welcome :)  Please ensure suitable tests cover any new functionality and that all tests are passing before and after your development work:

```shell
bundle exec rake spec
```

## Who should use PDQTest?
You should use pdqtest if you find it increases your productivity and enriches your life

## Troubleshooting
* If you can't find the `pdqtest` command and your using `rbenv` be sure to run `rbenv rehash` after installing the gem to create the necessary symlinks

## Support
This software is not supported by Puppet, Inc.  Use at your own risk.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/declarativesystems/pdqtest.

### Running tests
* PDQTest includes a comprehensive tests for core library functions.  Please ensure tests pass before and after any PRs
* Run all tests `bundle exec rake spec`
* Run specific test file `bundle exec rspec ./spec/SPEC/FILE/TO/RUN.rb`
* Run specific test case `bundle exec rspec ./spec/SPEC/FILE/TO/RUN.rb:99` (where 99 is the line number of the test)
