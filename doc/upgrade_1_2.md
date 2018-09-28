geoff@computer:~/tmp/ssh$ git checkout -b pdk
Switched to a new branch 'pdk'
geoff@computer:~/tmp/ssh$ pdqtest init
Puppet metadata not found at metadata.json - not a valid puppet module
geoff@computer:~/tmp/ssh$ ls
total 72K
4.0K bitbucket-pipelines.yml  4.0K Gemfile       4.0K Makefile         4.0K Rakefile
4.0K CHANGELOG                4.0K Gemfile.lock  4.0K manifests        4.0K README.md
4.0K data                     4.0K hiera.yaml    4.0K metadata.json    4.0K REFERENCE.md
4.0K examples                  12K LICENSE       4.0K Puppetfile.lock  4.0K spec
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
geoff@computer:~/tmp/ssh$ cat Makefile 
all:
	cd .pdqtest && pwd && bundle exec pdqtest all
	$(MAKE) docs

fast:
	cd .pdqtest && pwd && bundle exec pdqtest fast

shell:
	cd .pdqtest && pwd && bundle exec pdqtest --keep-container acceptance

setup:
	cd .pdqtest && pwd && bundle exec pdqtest setup

shellnopuppet:
	cd .pdqtest && pwd && bundle exec pdqtest shell

logical:
	cd .pdqtest && pwd && bundle exec pdqtest syntax
	cd .pdqtest && pwd && bundle exec pdqtest rspec
	$(MAKE) docs

#nastyhack:
#	# fix for - https://tickets.puppetlabs.com/browse/PDK-1192
#	find vendor -iname '*.pp' -exec rm {} \;

pdqtestbundle:
	# Install all gems into _normal world_ bundle so we can use all of em
	cd .pdqtest && pwd && bundle install

docs:
	cd .pdqtest && pwd && bundle exec "cd ..&& puppet strings"


Gemfile.local:
	echo "[🐌] Creating symlink and running pdk bundle..."
	ln -s Gemfile.project Gemfile.local
	$(MAKE) pdkbundle

pdkbundle:
	pdk bundle install
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
