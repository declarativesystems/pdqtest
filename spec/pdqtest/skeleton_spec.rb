require "spec_helper"
require "pdqtest/skeleton"
require "fileutils"
require "pp"

describe PDQTest::Skeleton do

  it "creates testcase directory structure correctly and copies files" do
    testcase = File.expand_path(BLANK_MODULE_TESTDIR)
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        FileUtils.cp_r(testcase, ".")
        Dir.chdir(File.basename(testcase)) do
          PDQTest::Skeleton.init

          expect(Dir.exists?('spec')).to be true
          expect(Dir.exists?('spec/acceptance')).to be true
          expect(Dir.exists?('examples')).to be true

          # just check a few...
          expect(File.exists?('bitbucket-pipelines.yml')).to be true
          expect(File.exists?('.pdkignore')).to be true
          expect(File.exists?('.travis.yml')).to be true
        end
      end
    end
  end

  it "creates skeleton files if required" do
    testcase = File.expand_path(BLANK_MODULE_TESTDIR)
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        FileUtils.cp_r(testcase, "apache")
        Dir.chdir(File.basename("apache")) do

          PDQTest::Skeleton.init
          expect(File.exists?('Rakefile')).to be true
          expect(File.exists?('Makefile')).to be true
          expect(File.exists?(File.join('spec', 'acceptance', 'init.bats'))).to be true
          expect(File.exists?(File.join('spec', 'spec_helper.rb'))).to be true
          expect(File.exists?(File.join('spec', 'acceptance', 'init__setup.sh'))).to be true
          expect(File.exists?(File.join('spec', 'acceptance', 'init__before.bats'))).to be true
          expect(File.exists?(File.join('spec', 'acceptance', 'init.bats'))).to be true
          expect(File.exists?(File.join('examples', 'init.pp'))).to be true
          expect(File.exists?(GEMFILE)).to be true
          expect(File.readlines(GEMFILE).grep(/pdqtest/).any?).to be true=
        end
      end
    end
  end

  it "generates acceptance tests and examples for specific new example" do
    testcase = File.expand_path(BLANK_MODULE_TESTDIR)
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        FileUtils.cp_r(testcase, "apache")

        Dir.chdir('apache') do
          PDQTest::Skeleton.generate_acceptance(File.join('examples', 'newtests.pp'))
          expect(File.exists?(File.join('examples', 'newtests.pp'))).to be true

          expect(File.exists?(File.join('spec', 'acceptance', 'newtests__setup.sh'))).to be true
          expect(File.exists?(File.join('spec', 'acceptance', 'newtests__before.bats'))).to be true
          expect(File.exists?(File.join('spec', 'acceptance', 'newtests.bats'))).to be true
        end
      end
    end
  end

  it "generates acceptance tests and examples for specific existing example" do
    testcase = File.expand_path(BLANK_MODULE_TESTDIR)
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        FileUtils.cp_r(testcase, "apache")

        Dir.chdir('apache') do

          # test setup
          PDQTest::Skeleton.directory_structure
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
  end

  it "generates acceptance tests in bulk and preserves old content" do
    testcase = File.expand_path(BLANK_MODULE_TESTDIR)
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        FileUtils.cp_r(testcase, "apache")

        Dir.chdir('apache') do
          # test setup
          # bunch of existing examples and tests - must not be touched
          PDQTest::Skeleton.directory_structure
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

          PDQTest::Skeleton.generate_acceptance

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

  context "PDK skeleton files" do

    it "upgrades PDK 1x" do
      testcase = File.expand_path PDQTEST1X_MODULE_TESTDIR
      Dir.mktmpdir do |tmpdir|
        Dir.chdir tmpdir do
          FileUtils.cp_r(File.join(testcase, "/.") , ".")
          PDQTest::Skeleton.install_pdk_skeletons

          old_rakefile_md5 = Digest::MD5.file(
              File.join(testcase,"Rakefile")
          ).hexdigest
          old_gemfile_md5 = Digest::MD5.file(
              File.join(testcase,"Gemfile")
          ).hexdigest
          old_spec_helper_md5 = Digest::MD5.file(
              File.join(testcase,"spec/spec_helper.rb")
          ).hexdigest
          # .rspec is presently identical PDK vs PDQTest

          new_rakefile_md5    = Digest::MD5.file("Rakefile").hexdigest
          new_gemfile_md5     = Digest::MD5.file("Gemfile").hexdigest
          new_spec_helper_md5 = Digest::MD5.file("spec/spec_helper.rb").hexdigest

          expect(old_rakefile_md5).not_to eq(new_rakefile_md5)
          expect(old_gemfile_md5).not_to eq(new_gemfile_md5)
          expect(old_spec_helper_md5).not_to eq(new_spec_helper_md5)
        end
      end
    end

    it "does not overwrite customised files" do
      testcase = File.expand_path PDQTEST1X_CUSTOM_MODULE_TESTDIR
      Dir.mktmpdir do |tmpdir|
        Dir.chdir tmpdir do
          FileUtils.cp_r(File.join(testcase, "/.") , ".")
          expect {
            PDQTest::Skeleton.install_pdk_skeletons
          }.to raise_error(/customised file/)
        end
      end
    end


    it "does not touch files when PDK already installed" do
      testcase = File.expand_path PDK_SNIFF_MODULE_TESTDIR
      Dir.mktmpdir do |tmpdir|
        Dir.chdir tmpdir do
          FileUtils.cp_r(File.join(testcase, "/.") , ".")
          PDQTest::Skeleton.install_pdk_skeletons

          old_rakefile_md5 = Digest::MD5.file(
              File.join(testcase,"Rakefile")
          ).hexdigest
          old_gemfile_md5 = Digest::MD5.file(
              File.join(testcase,"Gemfile")
          ).hexdigest
          old_spec_helper_md5 = Digest::MD5.file(
              File.join(testcase,"spec/spec_helper.rb")
          ).hexdigest
          # .rspec is presently identical PDK vs PDQTest

          new_rakefile_md5    = Digest::MD5.file("Rakefile").hexdigest
          new_gemfile_md5     = Digest::MD5.file("Gemfile").hexdigest
          new_spec_helper_md5 = Digest::MD5.file("spec/spec_helper.rb").hexdigest

          expect(old_rakefile_md5).to eq(new_rakefile_md5)
          expect(old_gemfile_md5).to eq(new_gemfile_md5)
          expect(old_spec_helper_md5).to eq(new_spec_helper_md5)
        end
      end

    end

  end
end
