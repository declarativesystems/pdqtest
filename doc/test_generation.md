# Test Generation
Creating a bunch of files manually is an error prone and tedious operation so PDQTest can generate files and boilerplate code for you so that your up and running in the quickest time possible.


## RSpec tests
The skeleton tests created by `pdqtest init` only cover the `init.pp` file which is useful but your likely going to need to support more classes as your modules grow.  PDQTest can generate basic RSpec testcases for each new puppet **class** that exists in the manifests directory for you:

```shell
bundle exec pdqtest generate_rspec
```

* For every `.pp` file containing a puppet class under `/manifests`, RSpec will be generated to:
  * Check the catalogue compiles
  * Check the catalogue contains an instance of the class

This gives developers an easy place to start writing additional RSpec tests for specific behaviour

Its safe to run this command whenever you add a new class, it won't overwrite any existing RSpec testcases

## Acceptance tests

Generate boilerplate files for each example found (including those without a magic marker):

```shell
pdqtest generate_acceptance
```

Generate boilerplate files for one specific example:

```shell
pdqtest generate_acceptance examples/mynewthing.pp
```

Note:  This will also create examples/mynewthing.pp if you haven't created it yet
