require "spec_helper"
require "pdqtest/pdk"
describe PDQTest::Pdk do
  it "detects active PDK" do
    Dir.chdir PDK_SNIFF_MODULE_TESTDIR do
      expect(PDQTest::Pdk.is_pdk_enabled).to be true
    end
  end

  it "detects inactive PDK" do
    Dir.chdir PDQTEST1X_MODULE_TESTDIR do
      expect(PDQTest::Pdk.is_pdk_enabled).to be false
    end
  end

  it "merges configuration into .sync.yml" do
    Dir.mktmpdir do |tmpdir|
      Dir.chdir tmpdir do
        # create some content
        existing = { "some" => "content"}
        File.open(PDQTest::Pdk::SYNC_YML, 'w') { |f| YAML.dump(existing, f) }

        # add new stuff and check it was written
        data = { "new" => "stuff"}
        PDQTest::Pdk.amend_sync_yml(data)

        expect(File.exist?(PDQTest::Pdk::SYNC_YML)).to be true
        expect(File.readlines(PDQTest::Pdk::SYNC_YML).grep(/some/).any?).to be true
        expect(File.readlines(PDQTest::Pdk::SYNC_YML).grep(/new/).any?).to be true
      end
    end
  end

  it "creates .sync.yml if missing" do
    Dir.mktmpdir do |tmpdir|
      Dir.chdir tmpdir do

        # add new stuff and check it was written
        data = { "new" => "stuff"}
        PDQTest::Pdk.amend_sync_yml(data)

        expect(File.exist?(PDQTest::Pdk::SYNC_YML)).to be true
        expect(File.readlines(PDQTest::Pdk::SYNC_YML).grep(/new/).any?).to be true
      end
    end
  end

  it "does not update metadata.json if PDK already enabled" do
    Dir.mktmpdir do |tmpdir|
      Dir.chdir tmpdir do
        # write the fake PDK TAG
        File.open("metadata.json","w") do |f|
          f.write(JSON.pretty_generate({PDQTest::Pdk::PDK_VERSION_TAG => "99.99.99"}))
        end

        # take the MD5 of the current file
        md5_before = Digest::MD5.file("metadata.json").hexdigest

        PDQTest::Pdk.enable_pdk(
            {
              "pdk-version"  => "1.2.3",
              "template-url" => "http://pdk.megacorp.com/templates",
              "template-ref" => "deadbeef",
            }
        )

        md5_after = Digest::MD5.file("metadata.json").hexdigest

        # expect no change to file
        expect(md5_after).to eq(md5_before)

      end
    end
  end

  it "writes all of the PDK metadata tags" do
    # read real PDK metadata from testcase
    pdk_metadata = {}
    Dir.chdir PDK_SNIFF_MODULE_TESTDIR do
      pdk_metadata = PDQTest::Puppet.module_metadata
    end
    Dir.mktmpdir do |tmpdir|
      Dir.chdir tmpdir do
        # must write a blank metadata file first since it is required in all cases
        File.write(PDQTest::Puppet::METADATA, "{}")
        PDQTest::Pdk.enable_pdk(pdk_metadata)

        # make sure it all gets written to module
        module_metadata = PDQTest::Puppet.module_metadata
        expect(module_metadata["pdk-version"]).to eq("1.7.0")
        expect(module_metadata["template-url"]).to eq("https://github.com/puppetlabs/pdk-templates")
        expect(module_metadata["template-ref"]).to eq("tags/1.7.0-0-g57412ed")
      end
    end

  end

end