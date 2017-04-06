[![Build Status](https://travis-ci.org/declarativesystems/pdqtest.svg?branch=master)](https://travis-ci.org/declarativesystems/pdqtest)

# PDQTest

PDQTest - Puppet Docker Quick-test - is the quickest and easiest way to test your puppet modules. PDQTest features tests for:
* Linting
* Syntax
* RSpec
* Acceptance ([BATS](https://github.com/sstephenson/bats))

And can generate code to retrofit testing to a new or existing module, along with skeleton RSpec and acceptance tests to get you started.

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
To add PDQTests to a new or existing puppet module, run the command:
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

## About acceptance tests
* Acceptance tests run within a Docker container managed by PDQTest
* The Docker container breaks all the rules of Docker and runs a full version of Systemd to allow complete testing of Puppet code in the most portable way (basically treat docker as a high speed VM)... This is deliberate - PDQTest exists to get results, not be a perfect Docker app.
* The test container uses a minimal version of Centos 7, there's no option to change this at present
* The container will only be started if at least one example file is present and contains the correct magic marker
* You can get a shell on the docker container if needed:
  * A representitive system, identical to that which will be used to run the tests `pdqtest shell`
  * The actual container that was just used on a test run `pdqtest --keep-container all` and run the command indicated on exit

### Test workflow
1. Scan for all example files under `/examples`.  Files must end in `.pp` and contain the magic marker `#@PDQTest` to be processed
2. If example files are present, start the docker container
3. For each example file:
  * Check for a file at `/spec/acceptance/EXAMPLE_NAME__setup.sh`,   If it exists, run it inside the container.  This is a useful place to install preqrequisites, edit files, install mock services, clean up after other tests, etc.
  * Check for a file at `/spec/acceptance/EXAMPLE_NAME__before.bats`, If it exists run BATS against it.  This is normally used to check the system state is clean or that any test prerequisites have been setup correctly
  * Run `puppet apply` on the example file twice
  * Check for a file at `/spec/acceptance/EXAMPLE_NAME.bats`, If it exists run BATS against it.  This is normally used to check the state of the system after running puppet.  You can do things like check services are running, check files edited correctly, or basically anything that you can write in bash!
4. Destroy the container unless we were asked to keep it with `--keep-container`

Note: `EXAMPLE_NAME` is the example filename minus the directory and `.pp`, eg the `EXAMPLE_NAME` for `examples/foo.pp` would just be `foo`.

### Example files
* Found inside `/examples`
* Regular puppet code
* Will be executed _twice_ (to check for idempotency) with `puppet apply`
* _MUST_ contain the magic marker `#@PDQTest` on a line at the top of the file to indicate that this test should be processed by PDQTest
* Basically the same as a regular puppet [smoke test](https://docs.puppet.com/puppet/latest/tests_smoke.html#module-smoke-testing) but run automatically and with system state tests

### BATS tests
If you've never seen a BATS test before and have previously been writing server spec code, you'll probably kick youself when you see how simple they are.  Here's an example:

```BASH
# Tests are really easy! just the exit status of running a command...
@test "addition using bc" {
  result="$(ls /)"
  [ "$?" -eq 0 ]
}
```

Tests are all written in BASH and the testcase passes if the stanza returns zero.  This means that basically any Linux/Unix sysadmin is now empowered to write Testcases and do TDD - score!

Since our tests are written in BASH, there are of course all the usual bash quirks such as failing on incorrect spacing, bizzare variable quoting etc, but given the simplicity gained its a worthwhile tradeoff.

Consider the following (real) test:

```BASH
@test "ClientAliveCountMax" {
  grep "ClientAliveCountMax 1" /etc/ssh/sshd_config
}
```

Here, we have done exactly what it looks like we have done - checked for the value of a particular setting in a text file.  Since our tests our plain old BASH, it means we can do things like test daemons are running with `systemctl`, test ports are open with `netstat` and do complete system tests `wget` and `curl`.  Cool!

#### Worked Example
Lets say you have two examples, `foo.pp` and `init.pp`.  In this case, the full range of files to create for acceptance testing would look like this:
```
/home/geoff/github/ssh/
├── examples
│   ├── foo.pp
│   └── init.pp
├── ...
└── spec
    ├── acceptance
    │   ├── foo__before.bats
    │   ├── foo__setup.sh
    │   ├── foo.bats
    │   ├── init__before.bats
    │   ├── init__setup.sh
    │   └── init.bats
    ├── ...
```

* You can put any puppet code you like (includeing an empty file...) in each of the files under `/examples` and it will executed with `puppet apply`
* If you need to test multiple different things (eg different parameters for a new type and provider), you need to create different testcase for each distinct thing to test.  See below for help generating these
* You can skip setup or BATS testing before and/or after running `puppet apply` if desired by deleting the appropriate files
* If you delete all of the files under `spec/acceptance` for a given example, then PDQTest will just check that puppet runs idempotently for your example
* To disable tests temporarily for a specific example, remove the magic marker `#@PDQTest` from the desired example
* Nested examples (subdirectories) are not supported at this time

## Real world example
See https://github.com/GeoffWilliams/puppet-filemagic for a project with lots of acceptance tests.

## Test Generation
Creating a bunch of files manually is an error prone and tedious operation so PDQTest can generate files and boilerplate code for you so that your up and running in the quickest time possible.

### Skeleton
* `pdqtest init` will generate a basic set of tests to get you started (tests init.pp)

### RSpec tests
The skeleton tests created by `pdqtest init` only cover the `init.pp` file which is useful but your likely going to need to support more classes as your modules grow.  PDQTest can generate basic RSpec testcases for each new puppet class that exists in the manifests directory for you:

```shell
pdqtest generate_rspec
```

* For every `.pp` file containing a puppet class under `/manifests`, RSpec will be generated to:
  * Check the catalogue compiles
  * Check the catalogue contains an instance of the class
  * This gives developers an easy place to start writing additional RSpec tests for specific behaviour
  * Its safe to run this command whenever you add a new class, it won't overwrite any existing RSpec testcases

### Acceptance tests

#### Generate boilerplate files for each example found (including those without a magic marker)

```shell
pdqtest generate_acceptance
```

#### Generate boilerplate files for one specific example

```shell
pdqtest generate_acceptance examples/mynewthing.pp
```
* Note:  will also create examples/mynewthing.pp if you haven't created it yet


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
* Be sure to annotate the examples you wish to acceptance test with the magic marker comment `#@PDQTest`

## Support
This software is not supported by Puppet, Inc.  Use at your own risk.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/declarativesystems/pdqtest.

### Running tests
* PDQTest includes a comprehensive tests for core library functions.  Please ensure tests pass before and after any PRs
* Run all tests `bundle exec rake spec`
* Run specific test file `bundle exec rspec ./spec/SPEC/FILE/TO/RUN.rb`
* Run specific test case `bundle exec rspec ./spec/SPEC/FILE/TO/RUN.rb:99` (where 99 is the line number of the test)
