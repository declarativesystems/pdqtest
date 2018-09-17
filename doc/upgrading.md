# Upgrading
To upgrade the current version of PDQTest on your system:

```
gem update pdqtest
```

Each project you want to use the newer version of PDQTest on should then have 
it's `Gemfile.project` updated to reference the latest version.  Don't worry, 
this is easy:

```shell
cd /my/cool/project/to/upgrade
pdqtest upgrade
pdk bundle install
```

Note that since we're using bundler, you only have to upgrade the puppet modules
you want to upgrade.  Existing modules can continue to run any previous version
via `make` just fine. You are not forced to update all your modules in one go.

## Docker image
Updated docker images are periodically released and are required to run newer
PDQTest versions. When you get a message about missing docker containers run:

```shell
pdqtest setup
```

To obtain the latest version.

# PDQTest 1x -> 2x
PDQTest is now compatible with (and requires) PDK! By and large we let PDK do 
its own thing and just wrap the output with emojis and run our own acceptance
tests.

Since this is a major upgrade, you must re-init your project. Make sure all your
code is checked in to git, 
[install PDK](https://puppet.com/docs/pdk/1.x/pdk_install.html) then run:

```shell
gem install pdqtest
cd /my/project
pdqtest init
pdk bundle install
bundle exec pdqtest setup
```

## Custom facts
If you were previous using custom facts in the `spec/merge_facts` directory, 
these need to be converted to yaml and moved to `spec/default_facts.yml`. This
will give you compatibiliy between PDK unit tests and PDQTest acceptance tests.

## RSpec tests (inc hiera data)
PDQTest doesn't deal with RSPec tests any more, we let PDK do all the work by
shelling out to call `pdk test unit`:

* If you were using PDQTest for your hiera data during the RSpec lifecycle, 
  update your tests to do what PDK tells you to do
* Existing `spec/fixtures/hiera.yaml` and `spec/fixtures/test.yaml` files will
  continue to work during acceptance tests and the `hiera.yaml` file has been
  upgraded for hiera 5 compatibility. You will have to reconfigure your 
  hierarchy if you were using more files then just `test.yaml`

Tests themselves will fail due to missing dependency on 
[puppet_factset](https://rubygems.org/gems/puppet_factset) gem which is now no
longer required (by anything 😁).

You can enable this gem in PDK by adding it to `Gemfile.project` and running
`pdk bundle install` or you can just rewrite your tests using the new PDK format
which looks like this:

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

You can use PDK to generate these tests, see the PDK manual for details of how.

## `/spec/spec_helper.rb`
Any customisations in this file will be lost. It's now owned by PDK

## `/Gemfile`
Any customisations in this file will be lost. It's now owned by PDK

## `/Gemfile.project`
New file used for configuring which PDQTest gem to use (replaces customisation
of `Gemfile`) 

## `/cut` mountpoint
Previous versions of PDQTest mounted code at `/cut` (Code Under Test), the new
mountpoint is the more obvious `/testcase` and `/cut` no longer works.
