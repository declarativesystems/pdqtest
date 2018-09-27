all: Gemfile.local
	bundle exec pdqtest all

fast: Gemfile.local
	bundle exec pdqtest fast

shell: Gemfile.local
	bundle exec pdqtest --keep-container acceptance

shellnopuppet: Gemfile.local
	bundle exec pdqtest shell

logical: Gemfile.local
	bundle exec pdqtest syntax
	bundle exec pdqtest rspec

nastyhack:
	# fix for - https://tickets.puppetlabs.com/browse/PDK-1192
	find vendor -iname '*.pp' -exec rm {} \;

bundle:
	# Obtain puppet 5x and lock
	pdk bundle install
	# Install all gems into _normal world_ bundle so we can use all of em
	bundle install

Gemfile.local:
	echo "[🐌] Creating symlink and running pdk bundle..."
	ln -s Gemfile.project Gemfile.local
	make bundle



