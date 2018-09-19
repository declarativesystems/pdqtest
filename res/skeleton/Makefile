all:
	make symlink
	bundle exec pdqtest all

fast:
	make symlink
	bundle exec pdqtest fast

shell:
	make symlink
	bundle exec pdqtest --keep-container acceptance

shellnopuppet:
	make symlink
	bundle exec pdqtest shell

logical:
	make symlink
	bundle exec pdqtest syntax
	bundle exec pdqtest rspec

symlink:
	@if [ -f "Gemfile.local" ]; then \
		echo "Gemfile.local already exists. Append it to Gemfile.project and run again" ;\
		exit 1 ; \
	elif [ ! -L "Gemfile.local" ] ; then\
		echo "Creating symlink" ; \
		ln -s "Gemfile.project" "Gemfile.local" ; \
	else  \
		echo "symlink exists" ;\
	fi


