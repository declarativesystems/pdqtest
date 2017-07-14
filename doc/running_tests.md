# Running tests
If you just want to run all tests:

```shell
make
```

Alternatively, you can choose to run individul test phases directly:

## All tests (excludes documentation)

```shell
bundle exec pdqtest all
```

### Syntax

```shell
bundle exec pdqtest syntax
```

### Lint

```shell
bundle exec pdqtest lint
```

### RSpec

```shell
bundle exec pdqtest rspec
```

### Acceptance

```shell
bundle exec pdqtest acceptance
```
