require "spec_helper"
require "pdqtest/execution"

describe PDQTest::Execution do
  it "returns the correct exit status for a result object (normal/ok)" do
    res = {:OUT=>nil, :ERR=>nil, :STATUS=>0}
    expect(PDQTest::Execution.exec_status(res)).to be true
  end

  it "returns the correct exit status for a result object (normal/error)" do
    res = {:OUT=>nil, :ERR=>nil, :STATUS=>255}
    expect(PDQTest::Execution.exec_status(res)).to be false
  end

  it "returns the correct exit status for a result object (puppet/ok)" do
    res = {:OUT=>nil, :ERR=>nil, :STATUS=>0}
    expect(PDQTest::Execution.exec_status(res, true)).to be true

    res = {:OUT=>nil, :ERR=>nil, :STATUS=>2}
    expect(PDQTest::Execution.exec_status(res, true)).to be true
  end

  it "returns the correct exit status for a result object (puppet/error)" do
    res = {:OUT=>nil, :ERR=>nil, :STATUS=>4}
    expect(PDQTest::Execution.exec_status(res, true)).to be false
  end

end