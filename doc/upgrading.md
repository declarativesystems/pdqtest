# Upgrading
To upgrade the current version of PDQTest on your system:

```
gem update pdqtest
```

Each project you want to use the newer version of PDQTest on should then have it's `Gemfile` updated to reference the latest version.  Don't worry, this is easy:

```shell
cd /my/cool/project/to/upgrade
pdqtest upgrade
bundle install
```

Note that since we're using bundler, you only have to upgrade the modules you want to upgrade.  Existing modules can continue to run any previous version via `make` just fine.

## Docker image
The docker image will be updated as and when required.  Run:

```shell
pdqtest setup
```

To obtain the latest version.

## `/cut`
Previous versions of PDQTest mounted code at `/cut` (Code Under Test), the new mountpoint is the more obvious `/testcase`
