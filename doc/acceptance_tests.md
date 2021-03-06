# Acceptance tests
Acceptance tests run Puppet in apply mode inside a Docker container managed by
PDQTest.

The Docker container breaks all the rules of Docker and runs a full version of
Systemd to allow complete testing of Puppet code in the most portable way 
to basically treat docker as a high speed VM... This is deliberate - PDQTest 
exists to get results, not be a perfect Docker app.

There are three supported docker images:
* Centos 7
* Ubuntu 16.04
* Windows (microsoft/windowsservercore)

Centos is used by default, all other images are activated by the 
`operatingsystem_support` element of `metadata.json`:

**Windows**
```json
  "operatingsystem_support": [
    {
      "operatingsystem": "windows"
    }
  ],
```

**Ubuntu**
```json
  "operatingsystem_support": [
    {
      "operatingsystem": "Ubuntu"
    },
  ],
```

Notes:
* Centos is great for mocking systems like AIX... if you replace OS binaries as
  required in the `__setup.sh` scripts
* If you have a specific container you want to use, pass `--image-name` on the
  command line, it accepts a comma delimited list of image names to test on
* The container will only be started if at least one example file is present 
  **and contains the correct magic marker**
* You can get a shell on the docker container if needed, see 
  [Debugging failed builds](#debugging-failed-builds)
* See the [docker_images](../docker_images) folder for examples

## Test workflow
1. Scan for all example files under `/examples`.  Files must end in `.pp` and 
   contain the magic marker `#@PDQTest` or `#@PDQTestWin` to be processed
2. If example files are present, start the docker container
3. For each example file:
  * Check for a file at `/spec/acceptance/EXAMPLE_NAME__setup.(sh|ps1)`, If it
    exists, run it inside the container.  This is a useful place to install 
    preqrequisites, edit files, install mock services, replace OS binaries, 
    clean up after other tests, etc.
  * Check for a file at `/spec/acceptance/EXAMPLE_NAME__before.(bats|pats)`, If
    it exists run BATS or PATS against it.  This is normally used to check the
    system state is clean or that any test prerequisites have been setup 
    correctly (most of the time you can skip this)
  * Run `puppet apply` on the example file twice (to check idempotency)
  * Check for a file at `/spec/acceptance/EXAMPLE_NAME.(bats|pats)`, If it 
    exists run BATS/PATS against it.  This is normally used to check the state 
    of the system after running puppet.  You can do things like check services 
    are running, check files edited correctly, or basically anything that you 
    can write in bash (or PowerShell)!
4. Destroy the container unless we were asked to keep it with `--keep-container`

Note: `EXAMPLE_NAME` is the example filename minus the directory and `.pp`, eg
the `EXAMPLE_NAME` for `examples/foo.pp` would just be `foo`.

### Example files
* Found inside `/examples`
* Regular puppet code
* Will be executed _twice_ (to check for idempotency) with `puppet apply`
* _MUST_ contain the magic marker `#@PDQTest` or `#@PDQTestWin` on a line at the
  top of the file to indicate that this test should be processed by PDQTest
* Basically the same as a regular puppet 
  [smoke test](https://docs.puppet.com/puppet/latest/tests_smoke.html#module-smoke-testing) but run automatically and with system state tests

### BATS tests
If you've never seen a [BATS](https://github.com/bats-core/bats-core) test 
before and have previously been writing server spec code, you'll probably kick
yourself when you see how simple they are.

BATS lets you run tests anywhere you can run BASH.

Here's an example:

```BASH
# Tests are really easy! just the exit status of running a command...
@test "addition using bc" {
  result="$(ls /)"
  [ "$?" -eq 0 ]
}
```

Tests are all written in BASH and the testcase passes if the stanza returns 
zero.  This means that basically any Linux/Unix sysadmin is now empowered to 
write Testcases and do TDD - score!

Since our tests are written in BASH, there are of course all the usual bash 
quirks such as failing on incorrect spacing, bizzare variable quoting etc, 
but given the simplicity gained its a worthwhile tradeoff.

Consider the following (real) test:

```BASH
@test "ClientAliveCountMax" {
  grep "ClientAliveCountMax 1" /etc/ssh/sshd_config
}
```

Here, we have done exactly what it looks like we have done - checked for the 
value of a particular setting in a text file.  Since our tests our plain old 
BASH, it means we can do things like test daemons are running with `systemctl`,
test ports are open with `netstat` and do complete system tests `wget` and 
`curl`.  Cool!

### PATS tests
[PATS](https://github.com/declarativesystems/pats) is to testing with PowerShell
as BATS is to testing with BASH. PATS is currently experimental and lets you
write your tests using the same syntax as BATS but with the body of the tests
being executed with PowerShell. As always, the exit status of your PowerShell
fragment is the result of the test. Here's an example that tests the timezone
has been set as desired. In this case we have shelled out to run `cmd.exe` but
you could just run pure PowerShell if you like:

```
@test "sets the timezone correctly" {
  cmd /C "tzutil /g | findstr /C:`"New Zealand Standard Time`" "
}
```

PATS is used for testing on Windows.

#### What if my project needs testing on Windows and Linux?
At present you would need to run `pdqtest` twice - once in a Windows environment
and again in Linux.

This is because Docker doesn't let us run Windows and Linux on the same platform
at the same time (Because it's not magic... Actually newer Docker versions do 
support this on Windows by running Docker in muliple VMs...).

This probably isn't as big an issue as it looks since most projects are going to
cater to one specific OS family.

#### Worked Example
Lets say you have two examples, `foo.pp` and `init.pp`. The files for acceptance
testing would look like this:

```
mycoolmodule
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

When we run acceptance tests PDQTest will create a new container and then run:
1. `sh /testcase/spec/acceptance/foo_setup.sh`
2. `bats /testcase/spec/acceptance/foo__before.bats`
3. `puppet apply /testcase/examples/foo.pp`
4. `puppet apply /testcase/examples/foo.pp`
5. `bats /testcase/spec/acceptance/foo.bats`
6. `sh /testcase/spec/acceptance/init_setup.sh`
7. `bats /testcase/spec/acceptance/init__before.bats`
8. `puppet apply /testcase/examples/init.pp`
9. `puppet apply /testcase/examples/init.pp`
10. `bats /testcase/spec/acceptance/init.bats`

Errors at any stage of the process will cause the test suite to abort once the
error is returned.

### Debugging failed builds
PDQTest provides two targets to debug failed builds:
1. `make shell`/`.\make.ps1 shell` - Load a new docker container, run all tests,
   then print a message showing how to get a shell
2. `make shellnopuppet`/`.\make.ps1 shellnopuppet` - Load a new docker container
   and transport into it, without running Puppet
   
You may also want to run PDQTest directly to use a different image (Ubuntu) 
se `--image-name` to use a different image (Ubuntu)

```json
cd .pdqtest
bundle exec pdqtest --image-name declarativesystems/pdqtest-ubuntu:2018-08-29-0 shell
```

Inside the container:
* Your code is available at `/testcase`
* Any puppet modules you have installed at `/spec/fixtures/modules` will be
  available (note that `pdk build` removes these)
* Hiera and custom facts will be installed if configured

User is responsible for cleaning up the containers created in this mode

### Docker privileged mode
Sometimes you need to run in Docker privileged mode to enable tests to work - 
not ideal and if anyone else has a better idea please open a ticket with the
details. When privileged mode is required, run `pdqtest --privileged` and you
will have access.

WARNING: This grants the container access to the host
