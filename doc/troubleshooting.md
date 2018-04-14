# Troubleshooting
* If you can't find the `pdqtest` command and your using `rbenv` be sure to run `rbenv rehash` after installing the gem to create the necessary symlinks
* If your `pdqtest` command changes version randomly depending which directory your in and you are using `rvm` its probably because `rvm` overrides `cd` and does strange things. You can probably turn this off. Alternatively, use `rbenv`
* Don't forget to run `pdqtest setup` before your first `pdqtest` run to download/update the Docker image
* If you need to access private git repositories, make sure to use `fixtures.yml` not `.fixtures.yml`
* If you need a private key to access private repositories, set this up for your regular git command/ssh and `pdqtest` will reuse the settings
* Be sure to annotate the examples you wish to acceptance test with the magic marker comment `#@PDQTest`
* Sometimes you might get an error: `Could not resolve the dependencies.` when executing tests.  This message is from librarian puppet and usually indicates a conflict between the `metadata.json` files somewhere in the set of modules you are attempting to use or the presence of a `Puppetfile` in a directory above the module your testing.  Running the command `librarian-puppet install --path spec/fixtures/ --destructive --verbose` should give you enough information to resolve the error
* Be sure to run `make` or `bundle exec pdqtest all` to download dependencies when running acceptance tests.  Previous versions (re)downloaded modules as required from inside docker but this step has been replaced with a simple symlink to reduce the amount of downloading so the modules must already be present.
