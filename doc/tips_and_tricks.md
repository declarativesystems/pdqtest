# Tips and tricks
* You can put any puppet code you like (including an empty file...) in each of 
  the files under `/examples` and it will executed with `puppet apply` as long
  as it contains the magic marker `#@PDQTest` or `#@PDQTestWin`
* If you need to test multiple different things (eg different parameters for a 
  new type and provider), you need to create a different (acceptance) testcase
  for each distinct thing to test
* PDQTest will only execute the BATS tests and setup scripts that are present,
  you can delete some or all of these files if some steps aren't required.
* If no files are present under `spec/acceptance` for a given example, then 
  PDQTest will just check that puppet runs idempotently for your example
* To disable tests temporarily for a specific example, remove the magic marker 
  `#@PDQTest` or `#@PDQTestWin` from the example
* Nested examples (subdirectories) are not supported at this time
* Since all of the `*__setup.sh`/`*__setup.ps1` scripts are run in the container
  as `root`/`Administrator` before executing tests, they can be used to mock 
  _almost anything_ in the test system:
  * Replace system binaries to fake network operations
  * Add system binaries to simulate other operating systems such as AIX, 
    Solaris, etc
  * Create/copy files, directories, etc.
  * Install OS packages
  * Install python scripts to mock database servers using SQLite... 😉
* Files added by PDQTest >= 2.0 that are not originating from PDK are marked: 
  `*File originally created by PDQTest*`
* See [development](development.md) guide for how to turn on debugging and exit
  stack traces
