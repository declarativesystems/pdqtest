# PDK Integration

First off, what is PDK? PDK is Puppet's development kit. The bits we are 
interested in right now are:
* Validation `pdk validate...`
* Testing `pdk test...`
* Packaging `pdk build...`

There's a lot more to PDK then just running simple tests though, PDK includes
its own version of ruby and various other tools.

On Linux PDK behaves (or at least appears to behave...)like a thin wrapper 
around ruby, in the same vein as RBENV/RVM. On Windows, things are more involved
since it needs to install specific system libraries and reference them at
runtime somehow. This is why running `bundle install` on PDK project in windows
can cause strange and interesting blow-ups.

## What's the point of PDQTest if we have PDK?
PDQTest provides an easy way to run acceptance testings using light-weight
Docker VMs. It offers a different approach to 
[Beaker](https://github.com/puppetlabs/beaker):
* Minimal to no project configuration required (just `metadata.json`)
* Simple acceptance tests written in BASH or PowerShell
* Provide _good enough_ (but not perfect) testing:
    * Generic Ubuntu, Centos, Windows test environments 
    * Capable of mocking large/slow/networked systems by replacing or installing
      binaries inside the container at the OS level, eg:
      * Fake installation of Database server's by mocking the installer your
        puppet `exec` would call with a simple python script
      * Network tools such as `realmd` with a simple mock `realm` command
        written in Python
      * Complex OS commands that need to report different state between puppet
        runs can be mocked with Python and a small SQLite database or simple
        text files (eg the `sysctl` command)
      * Fake different Unix-like Operating Systems like AIX by just subverting
        the commands that your puppet code would have touched. This is 
        particularly useful in this case since there are no AIX desktop
        virtualisation solutions right now and there probably never will be
      * See [examples](examples.md) for real-world modules

Of course, this will only ever give you an approximation of a real-world system
but in many cases this is all that's needed. The complexity of setting up a
100% accurate test environment is a daunting task and one that may never provide
tangible benefits in terms of time saved and problems prevented.

If perfect accuracy is indeed required, then PDQTest is not what you are looking
for and you should look towards solutions like Beaker or 
[Kitchen CI](https://kitchen.ci/).

## How does PDQTest work with PDK? Do I have to choose?

No you don't have to choose! PDQTest integrates with PDK by making the minimal
amount of invasive changes:

**metadata.json**
* Enable PDK by adding `pdk-version`

**Gemfile.project**
* Add a reference to the `pdqtest` gem

**Miscellaneous skeletons**
When `pdqtest init` is run, we install a small set of skeleton files in the root
of your project. This is a one-off operation to get you started or upgrade
between major PDQTest versions. Files marked  🛠 were obtained verbatim from
using PDK 1.7.0 to generate a minimal project:
```
├── bitbucket-pipelines.yml
├── Gemfile 🛠
├── Makefile
├── make.ps1
├── .pdkignore 🛠
├── .puppet-lint.rc
├── Rakefile 🛠
├── spec
│   ├── default_facts.yml
│   ├── fixtures
│   │   ├── hieradata
│   │   │   └── test.yaml
│   │   └── hiera.yaml
│   └── spec_helper.rb 🛠
└── .travis.yml
```

The remaining files are specific to PDQTest - notably:
* `.travis.yml`
* `bitbucket-pipelines.yaml` 
Are completely different. We also provide handy files to add your hiera data and
facts if you need them, and add `Makefile` and `make.ps1` files for easy test
execution on Linux and windows.

## What happens when I upgrade PDQTest?
When a new version of PDQTest is released, upgrade by running:

```shell
gem install pdqtest
cd /your/project
pdqtest upgrade
pdk bundle install
```

This updates:
* Project gems in `Gemfile.project` (currently `pdqtest` and `puppet-strings`)
* Our CI and CLI integrations:
    * `Makefile`
    * `make.ps1`
    * `.travis.yml`
    * `bitbucket-pipelines.yml`
    
The final `pdk bundle install` command upgrades PDK's bundle to the include our
update and is critical to making the whole process work.

## What happens when I upgrade PDK?
PDK operates independently from PDQTest and maintains its own files. Your free
to run `pdk update` to upgrade the your files to the latest PDK templated ones
at any time.

To protect PDQTest files from alteration (notably `.travis.yml` and
`bitbucket-pipelines.yml`) you have a couple of options:
* Use git to revert any change by PDK
* Use `.sync.yml` to influence file (re)generation
  [blog](https://puppet.com/blog/guide-converting-module-pdk)
  [reference](https://github.com/puppetlabs/pdk-templates) 
  [example](https://github.com/puppetlabs/puppetlabs-apt/blob/master/.sync.yml) 

## How do I use PDK with PDQTest installed? What can and can't I do?
You can run any `pdk` command as described in the PDK documentation. PDQTest
does not stop you running anything. If you find this not to be the case please
open a [ticket](https://github.com/declarativesystems/pdqtest/issues)

## How do PDQTest lifecycle tests relate to PDK?

| PDQTest   | PDK                            |
| ---       | ---                            |
| `syntax`  | `pdk validate metadata,puppet` |
| `rspec`   | `pdk test unit`                |
| `build`   | `pdk build --force`            |    

* Previous `lint` subcommand was removed in PDQTest 2.0 as its now covered by 
  `syntax`

## What actually happens when I run PDQTest?

`bundle exec pdqtest all` is the default target executed by `make` and 
`.\make.ps1`. There are a few other targets that let you skip parts of the build
or run individual parts. The complete run looks like this: 

1. `pdk validate 'metadata,puppet'`
2. Install modules listed in the `metadata.json` file using R10K against a 
   temporary `Puppetfile` at `Puppetfile.pdqtest`
3. Generate a `.fixtures.yml` file based on `metadata.json` 
   Currently impacted by 
   [#47](https://github.com/declarativesystems/pdqtest/issues/47)
4. `pdk test unit`
5. Run all acceptance tests
6. `puppet strings generate --format=markdown` to generate `REFERENCE.md`
7. `pdk build --force` to generate your forge package

At each stage of the process, we output emoji's to keep you informed of
progress. Any failure prevents running the next phase of testing and lint errors
are considered failures.
 
### Technical details (code)
If anyone knows a better way to do this, I'd love to hear about it:
[PDQTest lifecycle](https://github.com/declarativesystems/pdqtest/blob/master/exe/pdqtest)
[PDK Wrapper](https://github.com/declarativesystems/pdqtest/blob/master/lib/pdqtest/pdk.rb)

## PDQTest is pretty slow!
This is a side effect of having to shell to run PDK via system calls. There's
really no other way to do this while maintaining full PDK compatiblity (if you
know different, please enlighten me).

That said you might just want to run syntax and lint tests and acceptance tests
as quick as possible, in which case run:

**Linux**
```
make fast
```

**Windows**
```json
.\make.ps1 fast
```

This runs the syntax and lint tests using the original `puppet-syntax` and
`puppet-lint` libraries. We can't guarantee PDK identical behaviour or 
compatibility when used this way but hey... its faster.

