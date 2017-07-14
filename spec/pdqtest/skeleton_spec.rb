require "spec_helper"
require "pdqtest/skeleton"
require "fileutils"
require "pp"
require 'fakefs/safe'

describe PDQTest::Skeleton do

  before do
    # copy in the whole project folder to a location identical to the current directory
    # so that the skeleton files can be loaded, since fakefs prevents access to
    # the real ones
    pwd = Dir.pwd
    config = File.expand_path('.')
    FakeFS::FileSystem.clone(config, pwd)
  end

  it "removes fixtures.yml" do
    config = File.expand_path(BLANK_MODULE_TESTDIR)
    FakeFS::FileSystem.clone(config, '/apache')

    FakeFS do
      Dir.chdir('/apache') do
        FileUtils.touch '.fixtures.yml'

        PDQTest::Skeleton.init
        # ..to be_an_existing_file doesn't work with fakefs...
        expect(File.exists?('.fixtures.yml')).to be false
        expect(File.exists?('.fixtures.yml.pdqtest_old')).to be true
      end
    end
  end

  it "creates testcase directory structure correctly" do
    config = File.expand_path(BLANK_MODULE_TESTDIR)
    FakeFS::FileSystem.clone(config, '/apache')

    FakeFS do
      Dir.chdir('/apache') do
        PDQTest::Skeleton.init

        expect(Dir.exists?('./spec')).to be true
        expect(Dir.exists?('./spec/acceptance')).to be true
        expect(Dir.exists?('./spec/classes')).to be true
        expect(Dir.exists?('./examples')).to be true
      end
    end
  end

  it "creates skeleton files if required" do
    config = File.expand_path(BLANK_MODULE_TESTDIR)
    FakeFS::FileSystem.clone(config, '/apache')

    FakeFS do
      Dir.chdir('/apache') do
        PDQTest::Skeleton.init
        expect(File.exists?('Rakefile')).to be true
        expect(File.exists?('Makefile')).to be true
        expect(File.exists?(File.join('spec', 'acceptance', 'init.bats'))).to be true
        expect(File.exists?(File.join('spec', 'spec_helper.rb'))).to be true
        expect(File.exists?('Rakefile.pdqtest_old')).to be true
        expect(File.exists?(File.join('spec', 'spec_helper.rb.pdqtest_old'))).to be true
        expect(File.exists?(File.join('spec', 'acceptance', 'init__setup.sh'))).to be true
        expect(File.exists?(File.join('spec', 'acceptance', 'init__before.bats'))).to be true
        expect(File.exists?(File.join('spec', 'acceptance', 'init.bats'))).to be true
        expect(File.exists?(File.join('examples', 'init.pp'))).to be true
        expect(File.exists?('Gemfile')).to be true
        expect(File.readlines('Gemfile').grep(/pdqtest/).any?).to be true
        expect(File.readlines('Gemfile').grep(/puppet-strings/).any?).to be true
      end
    end
  end

  it "generates acceptance tests and examples for specific new example" do
    config = File.expand_path(BLANK_MODULE_TESTDIR)
    FakeFS::FileSystem.clone(config, '/apache')

    FakeFS do
      Dir.chdir('/apache') do
        PDQTest::Skeleton.generate_acceptance(File.join('examples', 'newtests.pp'))
        expect(File.exists?(File.join('examples', 'newtests.pp'))).to be true

        expect(File.exists?(File.join('spec', 'acceptance', 'newtests__setup.sh'))).to be true
        expect(File.exists?(File.join('spec', 'acceptance', 'newtests__before.bats'))).to be true
        expect(File.exists?(File.join('spec', 'acceptance', 'newtests.bats'))).to be true
      end
    end
  end

  it "generates acceptance tests and examples for specific existing example" do
    config = File.expand_path(BLANK_MODULE_TESTDIR)
    FakeFS::FileSystem.clone(config, '/apache')

    FakeFS do
      Dir.chdir('/apache') do
        # test setup
        existing = File.join('examples', 'existing.pp')
        File.write(existing, '# preserved')

        PDQTest::Skeleton.generate_acceptance(existing)

        # check existing content not destroyed
        expect(File.readlines(existing).grep(/preserved/).any?).to be true

        # check new acceptance tests created
        expect(File.exists?(File.join('spec', 'acceptance', 'existing__setup.sh'))).to be true
        expect(File.exists?(File.join('spec', 'acceptance', 'existing__before.bats'))).to be true
        expect(File.exists?(File.join('spec', 'acceptance', 'existing.bats'))).to be true
      end
    end
  end

  it "generates acceptance tests in bulk and preserves old content" do
    config = File.expand_path(BLANK_MODULE_TESTDIR)
    FakeFS::FileSystem.clone(config, '/apache')

    FakeFS do
      Dir.chdir('/apache') do
        # test setup

        # bunch of existing examples and tests - must not be touched
        existing = [
          File.join('examples', 'existing.pp'),
          File.join('spec', 'acceptance', 'existing.bats'),
          File.join('spec', 'acceptance', 'existing__before.bats'),
          File.join('spec', 'acceptance', 'existing__setup.sh'),
        ]
        existing.each { |f|
          File.write(f, '# preserved')
        }

        # A new example with no tests - they should be created
        new_example = File.join('examples', 'new_example.pp')
        File.write(new_example, '# preserved')

        PDQTest::Skeleton.generate_acceptance()

        # check existing tests not touched
        existing.each { |f|
          expect(File.readlines(f).grep(/preserved/).any?).to be true
        }

        # check new example not touched
        expect(File.readlines(new_example).grep(/preserved/).any?).to be true
        # check new testcases created
        expect(File.exists?(File.join('spec', 'acceptance', 'new_example__setup.sh'))).to be true
        expect(File.exists?(File.join('spec', 'acceptance', 'new_example__before.bats'))).to be true
        expect(File.exists?(File.join('spec', 'acceptance', 'new_example.bats'))).to be true
      end
    end

  end

end
