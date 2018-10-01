# Puppet facts
PDQTest uses PDK's `spec/default_facts.yml` to add facts to acceptance tests as
external facts.

During test setup, PDQTest will installing the file at one of:
* `/etc/puppetlabs/facter/facts.d/default_facts.yaml`
* `C:\ProgramData\PuppetLabs\facter\facts.d`

PDK uses the file as part of the `pdk test unit` command. This way you have a 
consistent set of facts for both RSpec and acceptance testing, in the file that
PDK expects them to be in.

## 🐉 Differences from PDK 🐉
The above behaviour is _not_ how PDK intends this file to be used as some other 
mechanism is supposed to be used for acceptance tests.

It's pretty rare to actually need `spec/default_facts.yml` unless your doing
unit testing since you can insert custom facts as part of your test setup 
script (eg `spec/fixtures/init__setup.sh`).

Be aware that PDK sets a few facts to specific values that we will pick up and
use in your acceptance tests:

```yaml
concat_basedir: "/tmp"
ipaddress: "172.16.254.254"
is_pe: false
macaddress: "AA:AA:AA:AA:AA:AA"
```

You would need to use a forked version of the PDK templates to fix these
properly, but your using the structured facts anyway so it makes no difference,
right...?
