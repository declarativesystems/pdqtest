require "spec_helper"
# don't remove pp - it's needed for fakefs! (duh...)
require "pp"
require "pdqtest/upgrade"
require 'fakefs/safe'

describe PDQTest::Upgrade do
  it "upgrades pdqtest and puppet-strings gems" do
    config = File.expand_path(UPGRADE_MODULE_TESTDIR)
    FakeFS::FileSystem.clone(config, '/upgrade_module')

    FakeFS do
      Dir.chdir('/upgrade_module') do
        PDQTest::Upgrade.upgrade
        expect(File.readlines('Gemfile').grep(/pdqtest/).any?).to be true
        expect(File.readlines('Gemfile').grep(/puppet-strings/).any?).to be true

        # make sure we dont mess up things we're not supposed to touch
        expect(File.readlines('Gemfile').grep(/gem 'no_touch',/).any?).to be true
        expect(File.readlines('Gemfile').grep(/:path => "\/foo\/bar"/).any?).to be true
      end
    end
  end
end
