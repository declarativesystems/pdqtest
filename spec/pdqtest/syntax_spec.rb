require "spec_helper"
require "pdqtest/syntax"

describe PDQTest::Syntax do
  it "passes on syntax good" do
    Dir.chdir(PASSING_TESTS_TESTDIR) {
      status = PDQTest::Syntax.puppet
      expect(status).to be true
    }
  end

  it "fails on syntax fail" do
    Dir.chdir(FAILING_TESTS_TESTDIR) {
      status = PDQTest::Syntax.puppet
      expect(status).to be false
    }
  end

  it "fails on missing Rakefile" do
    Dir.chdir(BLANK_MODULE_TESTDIR) {
      status = PDQTest::Syntax.puppet
      expect(status).to be false
    }
  end
end
