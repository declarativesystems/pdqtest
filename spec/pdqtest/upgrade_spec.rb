require "spec_helper"
require "pdqtest/upgrade"
require "tmpdir"
require "fileutils"

describe PDQTest::Upgrade do
  it "upgrades pdqtest and puppet-strings gems" do
    config = File.expand_path(UPGRADE_MODULE_TESTDIR)
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        FileUtils.cp_r(Dir.glob("#{config}/*"), '.')
        PDQTest::Upgrade.upgrade
        expect(File.readlines(GEMFILE).grep(/pdqtest/).first).to match PDQTest::VERSION
        expect(File.readlines(GEMFILE).grep(/puppet-strings/).first).to match /github.com/

        # make sure we dont mess up things we're not supposed to touch
        expect(File.readlines(GEMFILE).grep(/gem 'no_touch',/).any?).to be true
        expect(File.readlines(GEMFILE).grep(/:path => "\/foo\/bar"/).any?).to be true

      end
    end
  end

end
