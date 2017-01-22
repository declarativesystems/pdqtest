require "spec_helper"
require "pdqtest/lint"

describe PDQTest::Lint do
  it "passes on no lint" do
    Dir.chdir(PASSING_TESTS_TESTDIR) {
      status = PDQTest::Lint.puppet
      expect(status).to be true
    }
  end

  it "fails on linter error" do
    Dir.chdir(FAILING_TESTS_TESTDIR) {
      status = PDQTest::Lint.puppet
      expect(status).to be false
    }
  end

  it "fails on bad rakefile" do
    Dir.chdir(BLANK_MODULE_TESTDIR) {
      status = PDQTest::Lint.puppet
      expect(status).to be false
    }
  end
end
