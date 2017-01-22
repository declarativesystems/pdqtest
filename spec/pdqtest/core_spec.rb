require "spec_helper"
require "pdqtest/core"
require "pdqtest/lint"
require "pdqtest/syntax"

describe PDQTest::Core do
  module FunctionFixtures
    def self.failing_function
      false
    end

    def self.passing_function
      true
    end
  end

  it "runs " do
    
    # single function under test
    expect {
      PDQTest::Core::run(lambda {FunctionFixtures.passing_function})
    }.not_to raise_error

    # array of functions under test
    expect {
      PDQTest::Core::run([
        lambda {FunctionFixtures.passing_function},
        lambda {FunctionFixtures.passing_function},
      ])
    }.not_to raise_error
  end

  it "aborts ruby when test failures encountered" do

    # immediate failure of a single function
    expect {
      PDQTest::Core::run(lambda {FunctionFixtures.failing_function})
    }.to raise_error SystemExit

    # failure after successful functions
    expect {
      PDQTest::Core::run([
        lambda {FunctionFixtures.passing_function},
        lambda {FunctionFixtures.failing_function},
      ])
    }.to raise_error SystemExit
  end
end
