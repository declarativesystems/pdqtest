# $LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
# require 'simplecov'
#
# SimpleCov.start
# require "pdqtest"
require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'simplecov'



#$: << File.expand_path('../../lib', __FILE__)
require 'pdqtest'
require 'fakefs/safe'

RSpec.configure do |config|
  # config.before(:suite) do
  #   FakeFS.activate!
  # end

  config.after(:suite) do
    FakeFS.deactivate!
  end
end
