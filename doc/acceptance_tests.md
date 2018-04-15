# Acceptance tests
* Acceptance tests run within a Docker container managed by PDQTest
* The Docker container breaks all the rules of Docker and runs a full version of Systemd to allow complete testing of Puppet code in the most portable way (basically treat docker as a high speed VM)... This is deliberate - PDQTest exists to get results, not be a perfect Docker app.
* There are two supported docker images - Centos 7 and Ubuntu 16.04
* Centos is used by default
* Ubuntu will be used if your `metadata.json` declares compatibility with Ubuntu
* Centos is great for mocking systems like AIX... if you replace OS binaries as required in the `__setup.sh` scripts
* No idea what to do to test windows on linux :/ containers seem out of the question and VMs would involve licensing
* If you have a specific container you want to use, pass `--image-name` on the command line, it accepts a comma delimited list of image names to test on
* The container will only be started if at least one example file is present **and contains the correct magic marker**
* You can get a shell on the docker container if needed, see [Debugging failed builds](#debugging-failed-builds)
* See the [docker_images](../docker_images) folder for examples

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

### Debugging failed builds
PDQTest makes it easy to debug failed builds:

```shell
pdqtest shell
```

* Opens a shell inside the docker container that would be used to run tests
* Your code is available at `/testcase`

```shell
pdqtest --keep-container all
```
* Runs all tests, report pass/fail status
* Keeps the container Running
* After testing, the container used to run tests will be left running and a message will be printed showing how to enter the container used for testing.  Your code is avaiable at `/testcase`
* User is responsible for cleaning up the containers created in this mode

### Docker privileged mode
Sometimes you need to run in Docker privileged mode to enable tests to work - not ideal and if anyone else has a better idea please open a ticket with the details. When privileged mode is required, run `pdqtest --privileged` and you will have access.

WARNING: This grants the container access to the host
