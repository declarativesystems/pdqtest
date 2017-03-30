require "spec_helper"
require "pdqtest/rspec"

describe PDQTest::Rspec do
  it "converts class name to spec test ok - init.pp" do
    Dir.chdir(REGULAR_MODULE_TESTDIR) {
      f = PDQTest::Rspec::class2specfile('regular_module')
      expect(f).to eq './spec/classes/init_spec.rb'
    }
  end

  it "converts class name to spec test ok" do
    Dir.chdir(REGULAR_MODULE_TESTDIR) {
      f = PDQTest::Rspec::class2specfile('regular_module::something::else')
      expect(f).to eq './spec/classes/something/else_spec.rb'
    }
  end

end
