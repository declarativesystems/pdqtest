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

bundle:
	pdk bundle install

Gemfile.local:
	echo "[🐌] Creating symlink and running pdk bundle..."
	ln -s Gemfile.project Gemfile.local
	make bundle



