# Running tests
If you just want to run all tests:

**Linux**
```shell
make
```

**Windows**
```shell
.\make.ps1
```

Alternatively, you can choose to run different groups of tests by supplying a
target from this table:

| Target        | Description                                                            | PDK compatible? |
| ---           | ---                                                                    | ---             |
| all           | lint, syntax, rspec, acceptance, strings, build                        | yes             |
| fast          | lint, syntax, acceptance, strings, build                               | no              |
| shell         | run acceptance tests and print command to get a shell in the container | yes             |
| shellnopuppet | open a shell in the test container                                     | yes             |
| logical       | syntax, lint                                                           | yes             |

* PDK compatible means we run the `pdk` command for this part of the lifecycle


**Example**

**Linux**
```shell
make fast
```

**Windows**
```shell
.\make.ps1 fast
```

## Only run acceptance tests
```shell
bundle exec pdqtest acceptance
```


## See also

PDQTest help:
```shell
bundle exec pdqtest --help
```
