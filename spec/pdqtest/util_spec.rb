require "spec_helper"
require "pdqtest/util"

describe PDQTest::Util do
  it "joins directories OK - no ending slash" do
    # single function under test
    expect(
      PDQTest::Util.joinp("/foo/bar", "baz")
    ).to eq "/foo/bar/baz"
  end

  it "joins directories OK - ending slash" do
    # single function under test
    expect(
      PDQTest::Util.joinp("/foo/bar/", "baz")
    ).to eq "/foo/bar/baz"
  end

  it "joins lots of directories OK" do
    # single function under test
    expect(
        PDQTest::Util.joinp("/foo/bar/", "baz", "inky/", "blinky", "pinky", "clive")
    ).to eq "/foo/bar/baz/inky/blinky/pinky/clive"
  end

  it "converts volume hashes to bind arrays OK" do
    # single function under test
    expect(
        PDQTest::Util.volumes2binds({
                                        "foo" =>  {"bar" => "rw"},
                                        "foo1" => {"bar1" => "rw"},
                                    })
    ).to eq [
        "bar:foo:rw",
        "bar1:foo1:rw",
    ]
  end

end
