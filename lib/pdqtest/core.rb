require 'pdqtest'
require 'pdqtest/emoji'
module PDQTest
  module Core

    def self.run(functions)
      # wrap in array if needed
      functions = Array(functions)
      functions.each { |f|
        if ! f.call
          Escort::Logger.error.error "Error encountered running #{f.to_s}"

          # epic fail, exit program
          PDQTest::Emoji.final_status(false)
          abort("ABORTED - there are test failures! :(")
        end
      }

      # we passed already
      PDQTest::Emoji.final_status(true)
      true
    end

  end
end
