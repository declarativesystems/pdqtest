require "spec_helper"
require "quicktest/skeleton"
require "fileutils"
require 'fakefs/safe'

describe Quicktest::Skeleton do

  before do
    # copy in the whole project folder to a location identical to the current directory
    # so that the skeleton files can be loaded, since fakefs prevents access to
    # the real ones
    pwd = Dir.pwd
    config = File.expand_path('.')
    FakeFS::FileSystem.clone(config, pwd)
  end

  it "removes fixtures.yml" do
    config = File.expand_path('./spec/fixtures/blank_module')
    FakeFS::FileSystem.clone(config, '/apache')

    FakeFS do
      Dir.chdir('/apache') do
        FileUtils.touch '.fixtures.yml'

        Quicktest::Skeleton.init
        # ..to be_an_existing_file doesn't work with fakefs...
        expect(File.exists?('.fixtures.yml')).to be false
        expect(File.exists?('.fixtures.yml.quicktest_old')).to be true
      end
    end
  end

  it "creates testcase directory structure correctly" do
    config = File.expand_path('./spec/fixtures/blank_module')
    FakeFS::FileSystem.clone(config, '/apache')

    FakeFS do
      Dir.chdir('/apache') do
        Quicktest::Skeleton.init

        expect(Dir.exists?('./spec')).to be true
        expect(Dir.exists?('./spec/acceptance')).to be true
        expect(Dir.exists?('./spec/classes')).to be true
        expect(Dir.exists?('./examples')).to be true
      end
    end
  end

  it "creates skeleton files if required" do
    config = File.expand_path('./spec/fixtures/blank_module')
    FakeFS::FileSystem.clone(config, '/apache')

    FakeFS do
    puts File.read('/Users/geoff/github/quicktest/lib/quicktest/../../res/skeleton/Rakefile')
      Dir.chdir('/apache') do
        Quicktest::Skeleton.init
        expect(File.exists?('Rakefile')).to be true
        expect(File.exists?(File.join('spec', 'spec_helper.rb'))).to be true
        expect(File.exists?('Rakefile.quicktest_old')).to be true
        expect(File.exists?(File.join('spec', 'spec_helper.rb.quicktest_old'))).to be true
        expect(File.exists?(File.join('spec', 'acceptance', 'init__setup.sh'))).to be true
        expect(File.exists?(File.join('spec', 'acceptance', 'init__before.bats'))).to be true
        expect(File.exists?(File.join('spec', 'acceptance', 'init.bats'))).to be true
        expect(File.exists?(File.join('examples', 'init.pp'))).to be true
        expect(File.exists?('Gemfile')).to be true
        expect(File.readlines('Gemfile').grep(/quicktest/).any?).to be true
      end
    end
  end


end
