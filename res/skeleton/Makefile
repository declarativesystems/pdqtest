all:
	bundle exec pdqtest all
	bundle exec puppet strings generate --format=markdown

shell:
	bundle exec pdqtest --keep-container acceptance

logical:
	bundle exec pdqtest syntax
	bundle exec pdqtest lint
	bundle exec pdqtest rspec
