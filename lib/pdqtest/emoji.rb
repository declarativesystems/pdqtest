module PDQTest
  module Emoji

    # windows can only output emojii characters in powershell ISE *but* ISE
    # causes PDK to crash, so we need special lame emoji's for our windows users
    EMOJIS = {
        :windows => {
            :pass => ":-)",
            :fail => "●~*",
            :overall_pass => "=D",
            :overall_fail => "><(((*>",
            :slow => "(-_-)zzz",
            :shame => "(-_-)",
        },
        :linux => {
            :pass => "😬",
            :fail => "💣",
            :overall_pass => "😎",
            :overall_fail => "💩",
            :slow => "🐌",
        }
    }


    @@disable = false

    def self.disable(disable)
      @@disable = disable
    end

    def self.emoji(key)
      EMOJIS[Util.host_platform][key] || raise("missing emoji #{key}")
    end

    # Print a message prefixed with optional emoji to the STDOUT logger
    def self.emoji_message(key, message, level=::Logger::INFO)
      if ! @@disable
        message = "#{message} #{emoji(key)}"
      end
      $logger.add(level) { message }
    end

    # print cool emoji based on status
    def self.emoji_status(status, emoji_pass, emoji_fail, label)
      lable_string = "#{label}: "
      if ! @@disable
        if status
          # cool bananas
          $logger.info lable_string + emoji_pass
        else
          # boom! crappy code
          $logger.error lable_string + emoji_fail
        end
      end
    end

    # partial status when lots to do
    def self.partial_status(status, label)
      emoji_status(status, emoji(:pass), emoji(:fail), label)
    end

    # Overall program exit status
    def self.final_status(status)
      emoji_status(status, emoji(:overall_pass), emoji(:overall_fail), 'Overall')
    end
  end
end
