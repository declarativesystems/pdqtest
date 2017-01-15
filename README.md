[![Build Status](https://travis-ci.org/GeoffWilliams/quicktest.svg?branch=master)](https://travis-ci.org/GeoffWilliams/quicktest)

# Quicktest

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/quicktest`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Statistics
Without running puppet, spinning up containers and running bats tests took on average 1-3 seconds, vs ~15 with a hacked version of testkitchen, ~4 minutes with unhacked (when offline).

Thats a sick improvement!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'quicktest'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install quicktest

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Who should use Quicktest?
You should use quicktest if you find it increases your productivity and enriches your life

## Troubleshooting
* If you can't find the `quicktest` command and your using `rbenv` be sure to run `rbenv rehash` after installing the gem to create the necessary symlinks

## Support
This software is not supported by Puppet, Inc.  Use at your own risk.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/GeoffWilliams/quicktest.
