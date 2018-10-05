# Running tests

## Important
You **must** use the provided launch scripts `Makefile` or `make.ps1` to run
PDQTest, at least until your familiar with how PDQTest works. This is because 
PDQTest must always be run from the `.pdqtest` directory. See 
[PDK integration](pdk.md) for more information.

## Quickstart
If you just want to run all tests:

**Linux**
```shell
make
```

**Windows**
```shell
.\make.ps1
```

## Make targets
Alternatively, you can choose to run a `Makefile`/`make.ps1` target by supplying
an argument from this table:

| Target          | Description                                                            | PDK compatible? |
| ---             | ---                                                                    | ---             |
| `all`           | metadata, syntax, lint, rspec, acceptance, strings, build              | yes             |
| `fast`          | syntax, lint, rspec, acceptance, strings                               | no              |
| `acceptance`    | acceptance tests only                                                  | -               |
| `shell`         | run acceptance tests and print command to get a shell in the container | yes             |
| `setup`         | download required docker images for this version of PDQTest            | -               |
| `shellnopuppet` | open a shell in the test container                                     | yes             |
| `logical`       | metadata, syntax, lint, rspec, docs                                    | yes             |
| `pdqtestbundle` | install gems needed for PDQTest                                        | -               |
| `docs`          | generate `REFERENCE.md` using Puppet Strings                           | -               |
| `Gemfile.local` | symlink/copy `Gemfile.local` from `Gemfile.project` and re-bundle PDK  | yes             |
| `pdkbundle`     | re-bundle PDK                                                          | yes             |
| `clean`         | cleanup `/pkg` and `/spec/fixtures/modules`                            | -               |

**PDK compatible**
* yes: we run the `pdk` command for this part of the lifecycle
* no: we run an alternative command
* -: There is no corresponding `pdk` command

Fast mode requires `puppet` in your path (not installed via gem).

**Examples**

Test the module as quickly as possible:

*Linux*
```shell
make fast
```

*Windows*
```shell
.\make.ps1 fast
```


## See also

PDQTest help:
```shell
cd .pdqtest ; bundle exec pdqtest --help
```
