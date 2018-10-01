# Development

PRs welcome :)  Please ensure suitable tests cover any new functionality and 
that all tests are passing before and after your development work.

## Debugging
* run with `--verbosity debug` _and_ `--debug` (transitional while we sort out
  logging in escort)
* Debug docker API calls: `export EXCON_DEBUG=debug` or `set EXCON_DEBUG=debug` 
  then run `pdqtest` as normal
  
**Example**
```shell
cd .pdqtest
bundle exec pdqtest --debug --verbosity debug all
```

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
* If your using RubyMine, you can just right-click -> debug

## Why not use `pdk bundle exec` instead of having your own `Gemfile`?
I tried this originally and couldn't get it working. There's seems to be some
kind of memory error from trying to run `pdk` inside `pdk`. In the end, separate
`Gemfile`s turned out to be simpler and more robust. For full details see
[PDK Integration](pdk.md).

## Support
Interested in commercial support of PDQTest?  Please email 
sales@declarativesystems.com to discuss your needs.