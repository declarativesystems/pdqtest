module PDQTest
  module Util
    ENV='export TERM=xterm LC_ALL=C PATH=/usr/local/bats/bin:/opt/puppetlabs/puppet/bin:$PATH;'

    def self.resource_path(resource)
      joinp(File.dirname(File.expand_path(__FILE__)), "../../res/#{resource}")
    end

    def self.app_dir
      ".pdqtest"
    end

    def self.app_dir_expanded
      joinp(Dir.home, app_dir)
    end

    def self.host_platform
      Gem.win_platform? ? :windows : :linux
    end

    def self.is_windows
      host_platform == :windows
    end

    def self.shell
      # cmd.exe is basically broken under docker, use powershell
      is_windows ? "powershell" : "bash"
    end

    # need to wrap commands with shell to gain access to
    # shell functions like `cd` etc
    def self.wrap_cmd(cmd)
      if cmd =~ /^\s*$/ || cmd == "bash" || cmd == "powershell"
        raise "Missing command to wrap!"
      end

      if is_windows
        wrapped = [shell, "-command", "#{cmd} ; exit $LastExitCode"]
      else
        wrapped = [shell, "-c", "#{ENV} #{cmd}"]
      end

      wrapped
    end

    # File.join joins paths with `/` _always_ so we must create our own
    # function to join paths correctly for windows since using `/` in docker
    # is not gonna work
    def self.joinp(*args)
      File.join(args).gsub(File::SEPARATOR,
                                   File::ALT_SEPARATOR || File::SEPARATOR)
    end

    # 3x" --> 1x" seems only way to escape quotes to keep cmd.exe happy. also
    # need to use double quotes for all args or they get eaten
    def self.rm(f)
      is_windows ? "if (test-path '#{f}'){ Remove-Item '#{f}' -Recurse -Force}" : "rm -rf #{f}"
    end

    # @param link the symlink file
    # @param target the real file
    def self.mk_link(link, target)
      $logger.debug "symlink: #{link} <==> #{target}"
      if Util.is_windows
        Emoji.emoji_message(
            :shame,
            "symlinks not supported by ruby/puppet on windows doing COPY instead")
        # broken until ruby/puppet fixed cmd = "#{rm(link)} ; cmd /C mklink /D '#{link}' '#{target}'"

        # for regular files use `copy-time`, for trees use `robocopy` - since
        # files are in the container we have no idea what is a file or not so
        # just guess based on presence of filename extension
        if link =~ /\.[\w]+$/
          cmd = "copy-item '#{target}' -destination '#{link}'"
        else
          cmd = "robocopy '#{target}' '#{link}' /NFL /NDL /NJH /NJS /nc /ns /np /MIR /XD .git fixtures"
        end
      else
        cmd = "#{rm(link)} && mkdir -p #{File.dirname(link)} && ln -s #{target} #{link}"
      end

      cmd
    end

    def self.volumes2binds(volumes)
      # {test_dir => {pwd => 'rw'} + VOLUMES
      # ...to...
      # "pwd:test_dir:rw",
      volumes.map { |container_dir, host_mapping|
        host_mapping.map { |dir, mode|
          "#{dir}:#{container_dir}:#{mode}"
        }.first
      }
    end
  end
end
