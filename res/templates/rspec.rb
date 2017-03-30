require 'spec_helper'
describe '<%= classname %>' do
  context 'compiles ok' do
    it { should compile }
  end

    context 'with default values for all parameters' do
      it { should contain_class('<%= classname %>') }
    end
  end
