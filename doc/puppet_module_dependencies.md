# Puppet module dependencies
To test your puppet code, PDQTest needs to configured to obtain any modules the code being tested depends on.

## Specifying dependencies

### Public modules (PuppetForge)
Dependencies on public forge modules must be specified in your module's `metadata.json` file.

### Private modules (from git)
If you need to download modules from git, then you must populate the `fixtures` section of `fixtures.yml`, eg:

```
repositories:
  corporatestuff:
    repo: 'https://nonpublicgit.megacorp.com/corporatestuff.git'
    ref: 'mybranch'
```


## .fixtures.yml
There is no need to maintain a `.fixtures.yml` file and the presence of this file when using `pdqtest` is an error (note the leading period)

## Notes:
* The filename is for private modules is `fixtures.yml` NOT `.fixtures.yml`.  The leading dot had to be removed to avoid `puppetlabs_spec_helper` also detecting the file and trying to use it.
* The file format of `.fixtures.yml` and `fixtures.yml` for specifing git repositories is identical
* Only the repositories section of the file will be processed as we do not use `puppetlabs_spec_helper` to do this for us.
* We convert the dependencies from `metadata.json` to a temporary puppetfile store at `.Puppetfile.pdqtes` which is then installed using r10k