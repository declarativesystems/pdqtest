# Upgrading
To upgrade the current version of PDQTest on your system:

```
gem update pdqtest
```

Each project you want to use the newer version of PDQTest on should then have 
it's `.pdqtest/Gemfile` updated to reference the latest version.  Don't worry, 
this is easy:

**Linux**

```shell
cd /your/project
pdqtest upgrade
make pdqtestbundle
```

**Windows**

```shell
cd /your/project
pdqtest upgrade
.\make.ps1 pdqtestbundle
```

Note that since we're using bundler, you only have to upgrade the puppet modules
you want to upgrade.  Existing modules can continue to run any previous version
via `make` just fine. You are not forced to update all your modules in one go.

## Docker image
Updated docker images are periodically released and are required to run newer
PDQTest versions. When you get a message about missing docker containers run:

**Linux**

```shell
make setup
```

**Windows**

```shell
.\make.ps1 setup
```

To obtain the latest version.

## What happens during `pdqtest upgrade`?
We update:
* Project gems in `.pdqtest/Gemfile`
* Our CI and CLI integrations:
    * `Makefile`
    * `make.ps1`
    * `.travis.yml`
    * `bitbucket-pipelines.yml`
