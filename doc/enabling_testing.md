# Enabling testing 
PDQTest is enabled and configured on a per-project basis.

### New projects
New projects should be created using PDK: `pdk new module`. 

### Enabling
To add PDQTest to a new or existing puppet module, run the commands:

**Linux**
```shell
pdqtest init
make pdqtestbundle
make setup
```

**Windows**
```shell
pdqtest init
.\make.ps1 pdqtestbundle
.\make.ps1 setup
```

From the top level directory of your puppet module. This will install PDQTest 
into the `.pdqtest/Gemfile` and generate an example set of acceptance tests. 

The `make setup` step downloads Docker images for your test platform:

**Linux**
* Centos
* Ubuntu

**Windows**
* Windows (Windows-Servercore) 

PDQTest now integrates with and requires PDK, so ideally your module was 
previously generated with `pdk new module`. If this was not the case, PDQTest
will install the minimal integrations required to also enable PDK on the module.

PDK must already be present on the system for this to work.

Note:  Your puppet module *must* have a valid `metatadata.json` file.  Create
one by running `pdk convert` before running `pdqtest init` if you don't already
have one.  

If your creating a puppet module from scratch, try `pdk new module` to create a
complete module skeleton that includes a valid version of this file.
