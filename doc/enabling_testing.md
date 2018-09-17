# Enabling testing
To add PDQTest to a new or existing puppet module, run the commands:

```shell
pdqtest init
pdk bundle install
```

From the top level directory of your puppet module. This will install PDQTest 
into the `Gemfile.project` (for PDK's bundler), and generate an example set of
acceptance tests.  

You **must** run `pdk bundle install` to install PDQTest into PDK's bundle and
you **must not* run `bundle install` (ever!).

For more info see (PDK-1172)[https://tickets.puppetlabs.com/browse/PDK-1172]

PDK must already be present on the system for this to work.

Note:  Your puppet module *must* have a valid `metatadata.json` file.  Create
one before running `pdqtest init` if you don't already have one.  If your 
creating a puppet module from scratch, try `pdk new module` to create a
complete module skeleton that includes a valid version of this file.
