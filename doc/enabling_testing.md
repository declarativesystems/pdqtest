# Enabling testing
To add PDQTest to a new or existing puppet module, run the commands:

```shell
pdqtest init
bundle install
```

From the top level directory of your puppet module. This will install PDQTest into the `Gemfile` (for bundler), and generate an example set of acceptance tests.  The `bundle install` step will need development libraries installed if you haven't already obtained them.

Note:  Your puppet module *must* have a valid `metatadata.json` file.  Create one before running `pdqtest init` if you don't already have one.  If your creating a puppet module from scratch, try `puppet module generate` to create a complete module skeleton that includes a valid version of this file.
