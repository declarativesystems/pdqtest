all:
	bundle exec pdqtest all
	bundle exec puppet strings

shell:
	bundle exec pdqtest --keep-container acceptance

logical:
	bundle exec pdqtest syntax
	bundle exec pdqtest lint
	bundle exec pdqtest rspec
