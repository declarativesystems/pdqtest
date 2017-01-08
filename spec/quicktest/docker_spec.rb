require "spec_helper"
require "quicktest/docker"

describe Quicktest::Docker do
  it "wraps commands correctly" do
    cmd = 'ls -lR * && abcd'
    result = Quicktest::Docker::wrap_cmd(cmd)
    expect(result[0]).to eq('bash')
    expect(result[1]).to eq('-c')
    expect(result[2]).to match(/; ls -lR \* && abcd/)
  end
end
