# PDK Integration

First off, what is PDK? [PDK](https://github.com/puppetlabs/pdk/) is Puppet's 
development kit. The bits we are interested in right now are:
* Validation `pdk validate...`
* Testing `pdk test...`
* Packaging `pdk build...`

There's a lot more to PDK then just running simple tests though, PDK includes
its own version of ruby and various other tools.

On Linux PDK behaves (or at least appears to behave...) like a thin wrapper 
around ruby, in the same vein as RBENV/RVM. On Windows, things are more involved
since it needs to install specific system libraries and reference them at
runtime somehow. This is why running `bundle install` on PDK project in windows
can cause strange and interesting blow-ups (don't do that!).

## What's the point of PDQTest if we have PDK?
PDQTest provides an easy way to run acceptance tests using light-weight
Docker containers which we abuse to the point of treating them _almost_ like 
VMs in order to extract maximum speed. It offers a different approach to 
[Beaker](https://github.com/puppetlabs/beaker):
* Minimal to no project configuration required, just `metadata.json` and a few 
  other files we setup for you
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
      * Fake different Unix-like Operating Systems such as AIX by subverting the 
        commands that your puppet code would execute. This is particularly 
        useful in this case since there are no AIX desktop virtualisation 
        solutions right now and there probably never will be
      * See [examples](examples.md) for real-world modules using these
        techniques

Of course, this will only ever give you an approximation of a real-world system
but in many cases this is all that's needed. The complexity of setting up a
100% accurate test environment is a daunting task and one that may never provide
ROI vs the effort spent configuring and maintaining it.

If perfect accuracy is indeed required, then PDQTest is not what you are looking
for and you should look towards solutions like Beaker or 
[Kitchen CI](https://kitchen.ci/).

## How does PDQTest work with PDK? Do I have to choose?

No, you don't have to choose! PDQTest integrates with PDK by making the minimal
amount of invasive changes:

### New projects
New projects should be created using PDK: `pdk new module`. 

This will give you all the PDK versioned files you would ever need. When you run
`pdqtest init` on a new project created with PDK, we only copy in our own 
integration files and do not not touch the PDK generated files at all (the ones
marked 🛠 below).

After running `pdqtest init`, run `pdk update` to have PDK process the
`.sync.yml` we installed.

### Existing PDQTest projects
To make upgrading to PDQTest 2.0 + PDK easy for our existing users, we automate
the workflow normally carried out by `pdk convert`.

We do not include the entire set of files that would have been generated by
`pdk convert` or `pdk new module`. If you want the full set, you should run 
one of these commands yourself before `pdqtest init` and the resulting files 
will be left alone unless PDK starts writing new files that we are already 
using.

#### Key integration points

**metadata.json**

* Enable PDK by adding the fields:
    * `pdk-version`
    * `template-url`
    * `template-ref`
  The values for these fields are obtained automatically from PDK itself and are
  consistent with the system installed PDK (we generate a temporary project and 
  read files/values from it).

**Gemfile.project**

If you require PDK to know about a particular gem for your project, add it to
this file and then run:

*Linux*
```shell
make Gemfile.local
```

*Windows*
```shell
.\make.ps1 Gemfile.local
```

Depending on platform, this will symlink or copy `Gemfile.project` to 
`Gemfile.local` respectively, then run `pdk bundle install` to update PDK's 
knowledge of the new gem.


**Miscellaneous skeletons**

When `pdqtest init` is run, we install a small set of skeleton files in the root
of your project. This is a one-off operation to get you started and is _only_
done if your project is not already marked PDK compatible. 

After your module has been marked as PDK compatible, you must only manage these
files using PDK.

Skeletons are generated on the fly using PDK itself, so they are always 
up-to-date according to the PDK you have installed on your system.

### Existing non-PDQTest projects
If you have an existing Puppet project that does not use PDQTest or PDK (eg 
created by hand or with the old `puppet module generate` command), then the 
recommended way to enable PDQTest is to first enable PDK by running 
`pdk convert`, then follow the wizard.

You may then enable `PDQTest` by running `pdqtest init`.

Depending on the state of your project, you may be able to bypass the 
`pdk convert` process by just running `pdqtest init` but this isn't recommended
or supported.


### PDQTest directory structure
* 🛠 - File generated by PDK
* ⚡ - File updated/replaced when you run `pdqtest upgrade`:

```
├── appveyor.yml ⚡
├── bitbucket-pipelines.yml ⚡
├── Gemfile 🛠
├── Gemfile.local
├── Gemfile.project
├── .gitattributes 🛠
├── .gitignore 🛠
├── Makefile ⚡
├── make.ps1 ⚡
├── .pdkignore 🛠
├── .pdqtest
│   ├── Gemfile ⚡
│   └── Gemfile.lock
├── .puppet-lint.rc
├── Rakefile 🛠
├── spec
│   ├── default_facts.yml 🛠
│   ├── fixtures
│   │   ├── hieradata
│   │   │   └── test.yaml
│   │   └── hiera.yaml
│   └── spec_helper.rb 🛠
└── .travis.yml ⚡
```

Notes:
* `appveyor.yml` - Complete test suite for Windows modules
* `.travis.yml` - Complete test suite for Linux modules
* `bitbucket-pipelines.yaml` - logical testing only (unit/RSpec) 
* `.puppet-lint.rc` - Make lint errors test failures, ignore double quotes, etc
* `Makefile` - Essential launch script for Linux
* `make.ps1` - Essential launch script for Windows
* `spec/fixtures/hiera.yaml` - Mock system-wide `hiera.yaml` file
* `spec/fixtures/hieradata/test.yaml` - Mock system-wide hieradata
* `Gemfile.project` - Used to enable additional gems in PDK if needed (eg for 
  RSpec)
* `Gemfile.local` - Transient file created at runtime by `Makefile` or
  `make.ps1` to enable additional PDK gems see details below
* `.gitignore` - PDK has a massive list of files to ignore for new projects so
  these are imported and we add some of our own
* `.gitattributes` - PDK doesn't process this on `pdk update` so it ignores our
  `.sync.yml` customisations. This is handy to force LF for teams working on 
  windows
* `.pdqtest/Gemfile` - it's **impossible** to share a `Gemfile` with PDK
  (believe me I tried) Therefore we need our own and it lives here. See details
  below.
* `.pdqtest/Gemfile.lock` - corresponding lock for PDQTest

## Why are the launch scripts essential/How does the PDQTest gem load itself?

### Extra gems for `pdk` command
PDK provides its own `Gemfile` to select the gems available at runtime. There
are hooks in this file to load additional configuration from two locations:
* `~/.gemfile`
* `YOUR_PROJECT/Gemfile.local`

These are good for loading additional GEMs that run inside the PDK ruby
environment created by the `pdk` command _only_! PDK modifies it's `Gemfile` at
runtime according to the target being run and this which makes it unsafe for us
to load the `pdqtest` gem here, because the bundle will change while it is being
used. 

Using `pdk bundle exec` as basically an alias for `bundle exec` did not work as
PDQTest needs to call the `pdk` command for its lifecycle targets. This caused
serious errors on Windows.

We are not supposed to store permanent data in `Gemfile.local` as its in
PDK's generated `.gitignore`. The workaround to this is for us to create our own
per-project `Gemfile` with the gems we would have liked to have put in 
`Gemfile.local` and copy/symlink as required. 

The main use of this is to load additional gems during the `pdk test unit` phase
that without customising via `.sync.yml` or a custom template repository 
(although these should work too/instead).

For further background see: 
* [PDK-1177](https://tickets.puppetlabs.com/browse/PDK-1177) and 
* [#50](https://github.com/declarativesystems/pdqtest/issues/50) 

### Load PDQTest and supporting gems
Since PDK updates `Gemfile` during execution, the only sensible option for
loading PDQTest is to have our own directory containing our own `Gemfile` 
and `Gemfile.lock`:
* `.pdqtest/Gemfile`
* `.pdqtest/Gemfile.lock`

This affords complete separation from PDK and lets us use the provided ruby. The
only caveat is that we must `cd` into the `.pdqtest` directory before executing
the `pdqtest` command.

When you run `pdqtest upgrade`, it will update `.pdqtest/Gemfile` with the newer
version of the `pdqtest` gem.

As ever, the per-project `.pdqtest/Gemfile` means that we support side-by-side 
installation of all versions of PDQTest while letting PDK take over the main 
`Gemfile` ensures full PDK compatibility.

### `Makefile` and `make.ps1`
To support these two scenarios, `Makefile` and `make.ps1` automate the project
preparation (bundling/symlinking) by providing the following targets:
* `Gemfile.local`:
    * Windows: Copy `Gemfile.project` to `Gemfile.local`, replacing any content,
      then run `pdk bundle` to update PDKs gems
    * Linux: Symlink `Gemfile.local` to `Gemfile.project`, then run `pdk bundle`
      to update PDKs gems
* `pdqtestbundle` - run `bundle install` using system/custom ruby against
  `.pdqtest/Gemfile`
* `pdkbundle` - run `pdk bundle install` to re-bundle PDK

The remaining targets all work by jumping into the `.pdqtest` directory and then
using `.pdqtest/Gemfile` to launch `pdqtest`. This avoids users having to jump
around the project directories to get work done.

For this reason, you **must** launch PDQTest using the provided `Makefile` or
`make.ps1` scripts, at until your familiar with jumping to the `.pdqtest`
directory to run `bundle exec pdqtest` yourself.


## What happens when I upgrade PDQTest?
When PDQTest is upgraded, we update the files above marked ⚡ in your project. 
This doesn't impact PDK at all with the exception that we take over 
`.travis.yml` since the PDK one doesn't do what we want it to.

## What happens when I upgrade PDK?
PDK operates independently from PDQTest and maintains its own files. Your free
to run `pdk update` to upgrade the your files to the latest PDK templated ones
whenever you like.

To protect PDQTest files from alteration (notably `.travis.yml` and
`bitbucket-pipelines.yml`) we merge instructions to have PDK leave them alone
to `.sync.yml` (merging with any existing rules) to prevent churn.

If you have further customisations to PDK controlled files your options are:
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

| PDQTest   | PDK                                                                  |
| ---       | ---                                                                  |
| `logical` | `pdk validate metadata,puppet`, `pdk test unit`                      |
| `all`     | `pdk validate metadata,puppet`, `pdk test unit`, `pdk build --force` |
| `fast`    | N/A - run `puppet-lint` and `rake syntax` to finish faster           |

## What actually happens when I run PDQTest?

`bundle exec pdqtest all` is the default target executed by `make` and 
`.\make.ps1`. The complete run looks like this: 

1. `pdk validate 'metadata,puppet'`
2. Install modules listed in the `metadata.json` file using R10K against a 
   temporary `Puppetfile` at `Puppetfile.pdqtest`
3. Generate a `.fixtures.yml` file based on `metadata.json` 
4. `pdk test unit`
5. Run all acceptance tests
6. `puppet strings generate --format=markdown` to generate `REFERENCE.md`
7. `pdk build --force` to generate your forge package

At each stage of the process, we output emoji's to keep you informed of
progress. Any failure prevents running the next phase of testing and lint errors
are considered failures.
 
## PDQTest is pretty slow!
This is a side effect of having to shell out to run PDK via system calls. 
There's really no other way to do this while maintaining full PDK compatibility 
(if you know different, please open a ticket and let me know how).

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

## How do I automatically fix up my lint errors?

With PDK!:

```shell
pdk validate -a
```

## What's going on with Puppet Strings?
We use our own gem version of `puppet` and `puppet-strings` because
`puppet-strings` is not shipped by PDK.

We execute `puppet strings` outside of ruby for simplicity.