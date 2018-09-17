require 'logging'

# Fixme - this should be in escort...
# credit: Dylan Ratcliffe
module PDQTest
  module Logger
    def self.logger
      if ! $logger
        # here we setup a color scheme called 'bright'
        Logging.color_scheme('bright',
          :lines => {
            :debug => :blue,
            :info  => :white,
            :warn  => :yellow,
            :error => :red,
            :fatal => [:white, :on_red]
          }
        )

        Logging.appenders.stdout(
            'stdout',
            :layout => Logging.layouts.pattern(
                :pattern      => '%m\n',
                :color_scheme => 'bright'
            )
        )

        $logger = Logging.logger['Colors']
        $logger.add_appenders 'stdout'
        $logger.level = :info
      end
      $logger
    end
  end
end
