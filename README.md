[![Build Status](https://travis-ci.org/declarativesystems/pdqtest.svg?branch=master)](https://travis-ci.org/declarativesystems/pdqtest)

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

### PDQTest preparation
PDQTest needs to download a Docker image before running tests:

```
bundle exec pdqtest setup
```

This image is updated periodically, the above command will download the appropriate image for the version of `pdqtest` being used.

### Module dependencies/.fixtures.yml
There is no need to maintain a `.fixtures.yml` file and the presence of this file when using `pdqtest` is an error.

#### Public modules (PuppetForge)
Dependencies on public forge modules must be specified in your module's `metadata.json` file.

#### Private modules (from git)
If you need to download modules from git, then you must populate the `fixtures` section of `fixtures.yml`, eg:

```
repositories:
  corporatestuff:
    repo: 'https://nonpublicgit.megacorp.com/corporatestuff.git'
    ref: 'mybranch'
```

##### Notes:
* The filename is `fixtures.yml` NOT `.fixtures.yml`.  The leading dot had to be removed to avoid `puppetlabs_spec_helper` also detecting the file and trying to use it.
* The file format of `.fixtures.yml` and `fixtures.yml` for specifing git repositories is identical
* Only the repositories section of the file will be processed as we do not use `puppetlabs_spec_helper` to do this for us.

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
* Don't forget to run `pdqtest setup` before your first `pdqtest` run to download/update the Docker image
* If you need to access private git repositories, make sure to use `fixtures.yml` not `.fixtures.yml`
* If you need a private key to access private repositories, set this up for your regular git command/ssh and `pdqtest` will reuse the settings

## Support
This software is not supported by Puppet, Inc.  Use at your own risk.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/declarativesystems/pdqtest.

### Running tests
* PDQTest includes a comprehensive tests for core library functions.  Please ensure tests pass before and after any PRs
* Run all tests `bundle exec rake spec`
* Run specific test file `bundle exec rspec ./spec/SPEC/FILE/TO/RUN.rb`
* Run specific test case `bundle exec rspec ./spec/SPEC/FILE/TO/RUN.rb:99` (where 99 is the line number of the test)
