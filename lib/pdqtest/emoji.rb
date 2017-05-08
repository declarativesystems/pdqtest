module PDQTest
  module Emoji
    @@disable = false

    def self.disable(disable)
      @@disable = disable
    end

    # Print a message prefixed with optional emoji to the STDOUT logger
    def self.emoji_message(emoji, message)
      if ! @@disabled
        message = emoji + message
      end
      Escort::Logger.output.puts message
    end

    # print cool emoji based on status
    def self.emoji_status(status, emoji_pass, emoji_fail, label)
      lable_string = "#{label}: "
      if ! @@disable
        if status
          # cool bananas
          Escort::Logger.output.puts lable_string + emoji_pass
        else
          # boom! crappy code
          Escort::Logger.error.error lable_string + emoji_fail
        end
      end
    end

    # partial status when lots to do
    def self.partial_status(status, label)
      emoji_status(status, "😬", "💣", label)
    end

    # Overall program exit status
    def self.final_status(status)
      emoji_status(status, "😎", "💩", 'Overall')
    end
  end
end
