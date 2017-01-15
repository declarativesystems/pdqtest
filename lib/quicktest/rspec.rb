module Quicktest
  module Rspec
    def self.run
      system("bundle exec librarian-puppet install --path ./spec/fixtures/modules --destructive")
      system("bundle exec rake spec")
      puts 'nprmal laexit'
    end

  end
end
