module Quicktest
  module Rspec
    def self.run
      status = system("bundle exec librarian-puppet install --path ./spec/fixtures/modules --destructive")
      status &= system("bundle exec rake spec")

      status
    end

  end
end
