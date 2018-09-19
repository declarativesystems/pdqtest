require "spec_helper"
require "pdqtest/pdqtest1x"

describe PDQTest::PDQTest1x do
  context "detect files that are safe to upgrade" do

    it "detects old version of Rakefile" do
      Dir.chdir(PDQTEST1X_MODULE_TESTDIR) do
        expect(PDQTest::PDQTest1x.is_pdqtest_file("Rakefile")).to be true
      end
    end

    it "detects old version of .rspec" do
      Dir.chdir(PDQTEST1X_MODULE_TESTDIR) do
        expect(PDQTest::PDQTest1x.is_pdqtest_file(".rspec")).to be true
      end
    end

    it "detects old version of spec/spec_helper.rb" do
      Dir.chdir(PDQTEST1X_MODULE_TESTDIR) do
        expect(PDQTest::PDQTest1x.is_pdqtest_file("spec/spec_helper.rb")).to be true
      end
    end

    it "detects old version of Gemfile" do
      Dir.chdir(PDQTEST1X_MODULE_TESTDIR) do
        expect(PDQTest::PDQTest1x.is_pdqtest_file("Gemfile")).to be true
      end
    end
  end

  context "detect files that are not safe to upgrade" do

    it "detects custom version of Rakefile" do
      Dir.chdir(PDQTEST1X_CUSTOM_MODULE_TESTDIR) do
        expect(PDQTest::PDQTest1x.is_pdqtest_file("Rakefile")).to be false
      end
    end

    it "detects custom version of .rspec" do
      Dir.chdir(PDQTEST1X_CUSTOM_MODULE_TESTDIR) do
        expect(PDQTest::PDQTest1x.is_pdqtest_file(".rspec")).to be false
      end
    end

    it "detects custom version of spec/spec_helper.rb" do
      Dir.chdir(PDQTEST1X_CUSTOM_MODULE_TESTDIR) do
        expect(PDQTest::PDQTest1x.is_pdqtest_file("spec/spec_helper.rb")).to be false
      end
    end

    it "detects custom version of Gemfile" do
      Dir.chdir(PDQTEST1X_CUSTOM_MODULE_TESTDIR) do
        expect(PDQTest::PDQTest1x.is_pdqtest_file("Gemfile")).to be false
      end
    end

  end
end