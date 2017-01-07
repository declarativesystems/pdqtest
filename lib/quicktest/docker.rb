module Quicktest
  module Docker
    def run_tests
      container.start


      container.stop
    end
  end
end
