# Test Generation
Creating a bunch of files manually is an error prone and tedious operation so
PDQTest can generate files and boilerplate code for you so that your up and 
running in the quickest time possible.

## Acceptance tests

Generate boilerplate files for each example found (including those without a 
magic marker):

```shell
pdqtest generate_acceptance
```

Generate boilerplate files for one specific example:

```shell
pdqtest generate_acceptance examples/mynewthing.pp
```

This will also create examples/mynewthing.pp if you haven't created it yet.


## RSpec tests
PDQTest < 2.0 includes rspec test generation. This functionality is replaced by
PDK in later versions:

```shell
pdk new class
```

Generates Puppet classes _and_ RSpec tests

## Other files
You should investigate PDK for generating more boiler plate code for things like
types/providers, defined resources, etc.