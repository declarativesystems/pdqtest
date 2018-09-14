# Development

PRs welcome :)  Please ensure suitable tests cover any new functionality and 
that all tests are passing before and after your development work.

## Support
Interested in commercial support of PDQTest?  Please email 
sales@declarativesystems.com to discuss your needs.

## Debugging
* run with `--verbosity debug`
* Debug docker API calls: `export EXCON_DEBUG=debug` or `set EXCON_DEBUG=debug` 
  then run `pdqtest` as normal

## Contributing
Bug reports and pull requests are welcome on GitHub at 
https://github.com/declarativesystems/pdqtest.

### Running tests
* PDQTest includes a comprehensive tests for core library functions.  Please 
  ensure tests pass before and after any PRs
* Run all tests `bundle exec rake spec`
* Run specific test file `bundle exec rspec ./spec/SPEC/FILE/TO/RUN.rb`
* Run specific test case `bundle exec rspec ./spec/SPEC/FILE/TO/RUN.rb:99` 
  (where 99 is the line number of the test)
