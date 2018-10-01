# Troubleshooting
* If you can't find the `pdqtest` command and your using `rbenv` be sure to 
  run `rbenv rehash` after installing the gem to create the necessary symlinks
* If your `pdqtest` command changes version randomly depending which directory
  your in and you are using `rvm` its probably because `rvm` overrides `cd` and
  does strange things. You can probably turn this off. Alternatively, use 
  `rbenv`
* Don't forget to run `make setup` or `.\make.ps1 setup` before your first 
  PDQTest run to download/update the Docker image
* If you need to access private git repositories, make sure to use 
  `.fixtures.yml` not `fixtures.yml` (changed in 2.0.0)
* If you need a private key to access private repositories, set this up for your
  regular git command/ssh and PDK should reuse the settings
* Be sure to annotate the examples you wish to acceptance test with the magic
  marker comment `#@PDQTest` or `#@PDQTestWin`
* Be sure to run `make` or `.\make.ps1` to download dependencies when running 
  acceptance tests.  Previous versions (re)downloaded modules as required from 
  inside docker but this step has been replaced with a simple symlink to reduce 
  the amount of downloading so the modules must already be present.
* Update to the latest PDK before running PDQTest
* See the [PDQTest 1.x -> 2.x upgrade notes](upgrade_1_2.md) for other gotchas
