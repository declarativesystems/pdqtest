require "spec_helper"
require "pdqtest/docker"
require "docker-api"

describe PDQTest::Docker do
  it "wraps commands correctly" do
    cmd = 'ls -lR * && abcd'
    result = PDQTest::Docker::wrap_cmd(cmd)
    expect(result[0]).to eq('bash')
    expect(result[1]).to eq('-c')
    expect(result[2]).to match(/; ls -lR \* && abcd/)
  end

  it "returns the correct exit status for a result object (normal/ok)" do
    expect(PDQTest::Docker.exec_status([nil,nil,0])).to be true
  end

  it "returns the correct exit status for a result object (normal/error)" do
    expect(PDQTest::Docker.exec_status([nil,nil,255])).to be false
  end

  it "returns the correct exit status for a result object (puppet/ok)" do
    expect(PDQTest::Docker.exec_status([nil,nil,0], true)).to be true
    expect(PDQTest::Docker.exec_status([nil,nil,2], true)).to be true
  end

  it "returns the correct exit status for a result object (puppet/error)" do
    expect(PDQTest::Docker.exec_status([nil,nil,4], true)).to be false
  end

  it "starts a container correctly" do
    c = PDQTest::Docker.new_container('/testcase', PDQTest::Docker::IMAGES[:DEFAULT])
    expect(c.id.empty?).to be false
  end

  it "stop a container correctly" do
    c = PDQTest::Docker.new_container('/testcase', PDQTest::Docker::IMAGES[:DEFAULT])
    id = c.id
    PDQTest::Docker.cleanup_container(c)
    # must use braces with inspect to stop exception escaping
    # http://stackoverflow.com/a/4946723
    expect{::Docker::Container.get(id)}.to raise_error(Docker::Error::NotFoundError)
  end

  it "fallback to testing on centos (default) when no os specified in metadata" do
    Dir.chdir(BLANK_MODULE_TESTDIR) do
      images = PDQTest::Docker.acceptance_test_images
      puts images
      puts "**********"

      expect(images.size).to eq 1
      expect(images[0]).to eq PDQTest::Docker::IMAGES[:DEFAULT]
    end
  end

  it "test only on ubuntu when specified in metadata" do
    Dir.chdir(UBUNTU_MODULE_TESTDIR) do
      images = PDQTest::Docker.acceptance_test_images
      expect(images.size).to eq 1
      expect(images[0]).to eq PDQTest::Docker::IMAGES[:UBUNTU]
    end
  end


  it "test on ubuntu and centos (default) when specified in metadata" do
    Dir.chdir(MULTIOS_MODULE_TESTDIR) do
      images = PDQTest::Docker.acceptance_test_images
      expect(images.size).to eq 2
      expect(images.include?(PDQTest::Docker::IMAGES[:UBUNTU])).to be true
      expect(images.include?(PDQTest::Docker::IMAGES[:DEFAULT])).to be true
    end
  end

end
