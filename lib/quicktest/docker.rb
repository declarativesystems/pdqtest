module Quicktest
  module Docker
    ENV='term=xterm LC_ALL=C PATH=/usr/local/bats/bin:/opt/puppetlabs/puppet/bin:$PATH;'

    def self.wrap_cmd(cmd)
      ['bash',  '-c', "#{ENV} #{cmd}"]
    end
  end
end
