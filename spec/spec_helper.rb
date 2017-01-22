# $LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
# require 'simplecov'
#
# SimpleCov.start
# require "pdqtest"
require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'simplecov'


require 'pdqtest'
require 'fakefs/safe'

BLANK_MODULE_TESTDIR  = File.join('spec', 'fixtures', 'blank_module')
FAILING_TESTS_TESTDIR = File.join('spec', 'fixtures', 'failing_tests')
PASSING_TESTS_TESTDIR = File.join('spec', 'fixtures', 'passing_tests')


RSpec.configure do |config|
  config.after(:suite) do
    FakeFS.deactivate!
  end
end
