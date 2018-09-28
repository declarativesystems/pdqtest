# *File originally created by PDQTest*
# BATS test file to run before executing 'examples/init.pp' with puppet.
#
# For more info on BATS see https://github.com/bats-core/bats-core

# Tests are really easy! just the exit status of running a command...
@test "addition using bc" {
  result="$(ls /)"
  [ "$?" -eq 0 ]
}
