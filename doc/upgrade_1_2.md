# PDQTest 1x -> 2x upgrade notes
PDQTest is now compatible with (and requires) PDK! By and large we let PDK do 
its own thing and just wrap the output with emojis and run our own acceptance
tests.

See [PDK Integration](pdk.md) for details of how this works. 

Since this is a major upgrade, you must re-init your project. Make sure all your
code is checked in to git, 
[install PDK](https://puppet.com/docs/pdk/1.x/pdk_install.html) then run:

```shell
gem install pdqtest
cd /my/project
pdqtest init
make pdqtestbundle
make setup
```

## Custom facts
If you were previous using custom facts in the `spec/merge_facts` directory, 
these need to be converted to yaml and moved to `spec/default_facts.yml`. This
will give you compatibility between PDK unit tests and PDQTest acceptance tests.

## RSpec tests (inc hiera data)
PDQTest doesn't deal with RSPec tests any more, we let PDK do all the work by
shelling out to call `pdk test unit`:

* If you were using PDQTest for your hiera data during the RSpec lifecycle, 
  update your tests to do what PDK tells you to do
* Existing `spec/fixtures/hiera.yaml` and `spec/fixtures/test.yaml` files will
  continue to work during acceptance tests and the `hiera.yaml` file has been
  upgraded for hiera 5 compatibility. You will have to reconfigure your 
  hierarchy if you were using more files then just `test.yaml`

PDQTest 1x generated RSpec tests will fail due to missing dependency on 
[puppet_factset](https://rubygems.org/gems/puppet_factset) gem which is not used
for new PDK generated classes.

To fix you tests, either:

**Enable `puppet_factset` gem**

You can enable this gem in PDK by adding it to `Gemfile.project` and running:

*Linux*

```shell
make Gemfile.local
```

*Windows*

```shell
.\make.ps1 Gemfile.local
```

**Rewrite tests to new format**

PDK writes RSpec test using its own template which creates output like this:

```ruby
require 'spec_helper'

describe 'CHANGETHISTOYOURCLASSNAME' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
```

**Delete your RSpec tests**

If your in a hurry and have good acceptance tests, another quick fix would be to
just delete the RSpec tests and rely purely on acceptance testing. 

You will miss fast-failure due to invalid puppet code if you do this, and will
lose any specialised testing you had previously.


## `.fixtures.yml` and `fixtures.yml`
`.fixtures.yml` is back in PDQTest 2.0 (it's presence was an error in PDQTest 
1.x) and `fixtures.yaml` is no longer used.

If you would like to use test fixtures from git, add them to `.fixtures.yml` and
you can continue to use them as before. The rest of the file is generated for
you automatically by PDQTest based on `metadata.json` to support integration 
with PDK.

[More info on dependencies](puppet_module_dependencies.md)

## Old PDQtest 1x integration points
* `/spec/spec_helper.rb`
* `/Gemfile`
* `/Rakefile`
* `/.rspec`
We will do our best to detect any previous PDQTest generated versions of these
files. If known versions are found, we will upgrade you to the PDK version. If
an unknown file is found we will stop and ask you to move it out of the way
first. PDK will be responsible for these files now-on.

## How to resolve `unknown/modified file` errors during upgrade
1. Move your existing file out of the way
2. Run `pdqtest init`
3. See per-file upgrade notes below

**`/Gemfile`**

Add any custom gems that used to be in `Gemfile` to `Gemfile.project` and they
will be evaluated during `pdk bundle install` and available during 
`pdk test unit`.

To make gems available to PDQTest itself, add them to `.pdqtest/Gemfile`.

**Other files**

If the upgrade cannot detect where a file that needs replacing came from we ask
the user to move/delete it. Most other files can safely be updated without issue
but we ask you to confirm this.

## PDK Managed files
PDK regenerates files it manages you run `pdk update`. To customise these files
and have your changes persist between updates, you need to add them to 
`.sync.yml` which allows you to override _some_ settings in the 
[PDK default templates](https://github.com/puppetlabs/pdk-templates/).

If the templates don't support the customisation you want, the advice from 
Puppet is to fork and customise that repository, then configure PDK to use it.

Consult the PDK documentation for instructions on how to do this. 

## Miscellaneous files/directories
### `/.gitignore`
We no longer install or manage `.gitignore` for you and we don't upgrade it
either. PDK ships a default version and we use that if the initial file is 
missing.

### `/cut` mountpoint
Previous versions of PDQTest mounted code at `/cut` (Code Under Test), the new
mountpoint is the more obvious `/testcase` and `/cut` no longer works.

## R10K cache issues
PDQTest < 2.0 configured the r10k cache via `.r10k.yaml` which caused 
[#44](https://github.com/declarativesystems/pdqtest/issues/44). To fix this, we
now use the default r10k cache dir at `~/.r10k/cache` and don't write 
`.r10k.yaml` any more. You should remove any `.r10k.yaml` files from your 
project unless you need it for something specific.

## PDK validation errors when puppet code valid
PDK scans the `/pkg` directory and will choke if old files are present there:
[PDK-1183](https://tickets.puppetlabs.com/browse/PDK-1183)

To remove them:

*Linux*

```shell
make clean
```

*Windows*
```shell
.\make.ps1 shell
```

## What does a real update look like?
```shell
geoff@computer:~/tmp/ssh$ git checkout -b pdk
Switched to a new branch 'pdk'

geoff@computer:~/tmp/ssh$ pdqtest init
Doing one-time upgrade to PDK - Generating fresh set of files...
pdk (INFO): Creating new module: x
pdk (INFO): Module 'x' generated at path '/tmp/d20180929-15397-q82464/x', from template 'file:///opt/puppetlabs/pdk/share/cache/pdk-templates.git'.
pdk (INFO): In your module directory, add classes with the 'pdk new class' command.
new module x --skip-interview: 😬
Detected PDQTest 1.x file at spec/spec_helper.rb (will upgrade to PDK)
Detected PDQTest 1.x file at spec/default_facts.yml (will upgrade to PDK)
Detected PDQTest 1.x file at .pdkignore (will upgrade to PDK)
Detected PDQTest 1.x file at Gemfile (will upgrade to PDK)
Detected PDQTest 1.x file at Rakefile (will upgrade to PDK)
Detected PDQTest 1.x file at .gitignore (will upgrade to PDK)
Updated .sync.yml with {".travis.yml"=>{:unmanaged=>true}}
enabling PDK in metadata.json

geoff@computer:~/tmp/ssh$ git status
On branch pdk
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   .gitignore
	modified:   .travis.yml
	modified:   Gemfile
	modified:   Makefile
	modified:   Rakefile
	modified:   metadata.json
	modified:   spec/spec_helper.rb

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	.Puppetfile.pdqtest
	.librarian/
	.pdkignore
	.pdqtest/
	.puppet-lint.rc
	.sync.yaml
	Puppetfile.lock
	make.ps1
	spec/acceptance/init__before.bats
	spec/acceptance/init__setup.sh
	spec/default_facts.yml
	spec/fixtures/

no changes added to commit (use "git add" and/or "git commit -a")

geoff@computer:~/tmp/ssh$ make pdqtestbundle
# Install all gems into _normal world_ bundle so we can use all of em
cd .pdqtest && pwd && bundle install
/home/geoff/tmp/ssh/.pdqtest
Resolving dependencies...
Using rake 12.3.1
Using bundler 1.16.1
Using colored 1.2
Using cri 2.6.1
Using deep_merge 1.2.1
Using excon 0.62.0
Using multi_json 1.13.1
Using docker-api 1.34.2
Using nesty 1.0.2
Using escort 0.4.0
Using facter 2.5.1
Using multipart-post 2.0.0
Using faraday 0.13.1
Using faraday_middleware 0.12.2
Using fast_gettext 1.1.2
Using locale 2.1.2
Using text 1.3.1
Using gettext 3.2.9
Using gettext-setup 0.30
Using hiera 3.4.5
Using hocon 1.2.5
Using httpclient 2.8.3
Using little-plugger 1.1.4
Using log4r 1.1.10
Using logging 2.2.2
Using minitar 0.6.1
Using semantic_puppet 1.0.2
Using puppet_forge 2.2.9
Using r10k 2.6.4
Using thor 0.20.0
Using pdqtest 1.9.9beta6
Using puppet-resource_api 1.6.0
Using puppet 6.0.0
Using puppet-lint 2.3.6
Using rgen 0.8.2
Using yard 0.9.16
Using puppet-strings 2.1.0
Using puppet-syntax 2.4.1
Bundle complete! 5 Gemfile dependencies, 38 gems now installed.
Use `bundle info [gemname]` to see where a bundled gem is installed.

geoff@computer:~/tmp/ssh$ make
cd .pdqtest && pwd && bundle exec pdqtest all
/home/geoff/tmp/ssh/.pdqtest
pdk (INFO): Using Ruby 2.4.4
pdk (INFO): Using Puppet 5.5.6
[✔] Checking metadata syntax (metadata.json tasks/*.json).
[✖] Checking module metadata style (metadata.json).
[✔] Checking Puppet manifest syntax (**/**.pp).
[✔] Checking Puppet manifest style (**/*.pp).
warning: metadata-json-lint: metadata.json: Dependency puppetlabs-stdlib has an open ended dependency version requirement >= 4.15.0
validate 'metadata,puppet': 💣
Error encountered running #<Proc:0x000055595e990ce8@/home/geoff/.rbenv/versions/2.5.1/lib/ruby/gems/2.5.0/gems/pdqtest-1.9.9beta6/exe/pdqtest:91 (lambda)>
Overall: 💩
ABORTED - there are test failures! :(
Makefile:2: recipe for target 'all' failed
make: *** [all] Error 1
```

See the error? That came from PDK validating our metadata... Looks like this
module had invalid metadata all along. At this point tests can be re-run any 
time just by running `make`.

When all tests are passing again the update to PDQTest 2.0/PDK is complete.