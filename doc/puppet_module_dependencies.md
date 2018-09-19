# Puppet module dependencies
To test your puppet code, PDQTest needs to configured to obtain any modules the
code being tested depends on.

## Specifying dependencies

### Public modules (PuppetForge)
Dependencies on public forge modules must be specified in your module's 
`metadata.json` file. When tests are run, we will use this to generate a 
temporary `Puppetfile` at `Puppetfile.pdqtest` which we will then install into
`spec/fixtures/modules` using R10K.

When RSpec tests are run using PDQtest a `.fixtures.yml` file will be generated
for you based on the module metadata (with PDK standalone you must update this
file manually). We will then execute `pdk test unit` on your behalf which will
install any additional modules from git that can't be specified in 
`metadata.json`.

This means you get a complete set of modules in `/spec/fixtures/modules` by the
time you come to run acceptance tests.

### Private modules (from git)
If you need to download modules from git, then you must populate the `fixtures`
section of `.fixtures.yml`, eg:

```
fixtures:
  repositories:
    camera_shy:
      repo: "git://git.megacorp.com/puppet/camera_shy"
      ref: "2.6.0"
```

It is an error to define the same module in both `metadata.json` and 
`.fixtures.yml` and the results of doing this are undefined:
* Always use `metadata.json` for public forge modules and we will update 
  `.fixtures.yml` based on it
* Modules from git should _only_ be defined in `.fixtures.yml`

## Notes:
* The file format of `.fixtures.yml` and `fixtures.yml` for specifing git 
  repositories is identical
* Previous versions of pdqtest configured the r10k cache via `.r10k.yaml` which
  caused [#44](https://github.com/declarativesystems/pdqtest/issues/44). To fix
  this, we now use the default r10k cache dir at `~/.r10k/cache` and don't write
  `.r10k.yaml` any more. You should remove any `.r10k.yaml` files from your 
  project unless you need it for something specific.