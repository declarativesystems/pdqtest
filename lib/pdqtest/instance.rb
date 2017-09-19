require 'docker-api'
require 'pdqtest/puppet'
require 'pdqtest/docker'
require 'escort'

module PDQTest
  module Instance
    TEST_DIR='/testcase'
    @@keep_container = false
    @@active_container = nil
    @@image_name = false

    def self.get_active_container
      @@active_container
    end

    def self.get_keep_container
      @@keep_container
    end

    def self.set_keep_container(keep_container)
      @@keep_container = keep_container
    end

    def self.set_docker_image(image_name)
      @@image_name =
          if image_name
            Array(image_name.split(/,/))
          else
            false
          end
    end

    def self.run(example=nil)
      # needed to prevent timeouts from container.exec()
      Excon.defaults[:write_timeout] = 10000
      Excon.defaults[:read_timeout] = 10000
      status = true

      # remove reference to any previous test container
      @@active_container = nil

      if PDQTest::Puppet::find_examples().empty?
        Escort::Logger.output.puts "No acceptance tests found, annotate examples with #{PDQTest::Puppet::MAGIC_MARKER} to make some"
      else
        # process each supported OS
        test_platforms = @@image_name || Docker::acceptance_test_images
        Escort::Logger.output.puts "Acceptance test on #{test_platforms}..."
        test_platforms.each { |image_name|
          Escort::Logger.output.puts "--- start test with #{image_name} ---"
          @@active_container = PDQTest::Docker::new_container(TEST_DIR, image_name)
          Escort::Logger.output.puts "alive, running tests"
          status &= PDQTest::Puppet.run(@@active_container, example)

          if @@keep_container
            Escort::Logger.output.puts "finished build, container #{@@active_container.id} left on system"
            Escort::Logger.output.puts "  docker exec -ti #{@@active_container.id} bash "
          else
            PDQTest::Docker.cleanup_container(@@active_container)
            @@active_container = nil
          end

          Escort::Logger.output.puts "--- end test with #{image_name} (status: #{status})---"
        }
      end
      Escort::Logger.output.puts "overall acceptance test status=#{status}"
      status
    end

    def self.shell
      # pick the first test platform to test on as our shell - want to do a specific one
      # just list it with --image-name
      image_name = (@@image_name || Docker::acceptance_test_images).first
      Escort::Logger.output.puts "Opening a shell in #{image_name}"
      @@active_container = PDQTest::Docker::new_container(TEST_DIR, image_name)

      # In theory I should be able to get something like the code below to
      # redirect all input streams and give a makeshift interactive shell, howeve
      # I'm damned if I get get this to do anything at all, so instead go the
      # easy way and start the container running, then use system() to redirect
      # all streams using the regular docker command.  Works a treat!
      # @@active_container.tap(&:start).attach(:tty => true)
      # @@active_container.exec('bash', tty: true).tap(&:start).attach( :tty => true, :stdin => $stdin) { |out, err|
      #   puts out
      #   puts err
      # }
      system("docker exec -ti #{@@active_container.id} bash")
      if @@keep_container
        Escort::Logger.output.puts "finished build, container #{@@active_container.id} left on system"
        Escort::Logger.output.puts "  docker exec -ti #{@@active_container.id} bash "
      else
          PDQTest::Docker.cleanup_container(@@active_container)
          @@active_container = nil
      end
    end
  end
end
