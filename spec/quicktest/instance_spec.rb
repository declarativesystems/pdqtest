require "spec_helper"
require "quicktest/docker"
require "quicktest/instance"

describe Quicktest::Instance do
  it "leaves container running when instructed" do
    Dir.chdir('spec/fixtures/correct_test_structure') do
      Quicktest::Instance::set_remove_container(false)
      Quicktest::Instance.run
      container = Quicktest::Instance::get_active_container
      expect(container).not_to eq(nil)
      instance = Docker::Container.get(container.id)
      expect(instance).not_to eq(nil)

      # now cleanup after ourselves
      container.delete(:force => true)
    end
  end

  it "closes container when instructed" do
    Dir.chdir('spec/fixtures/correct_test_structure') do
      Quicktest::Instance::set_remove_container(true)
      Quicktest::Instance.run
      c = Quicktest::Instance::get_active_container
      expect(c).to eq(nil)
    end
  end
end
