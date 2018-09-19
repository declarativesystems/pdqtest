require 'pdqtest/puppet'
require 'pdqtest/docker'
require 'pdqtest/instance'
require 'pdqtest/emoji'
require 'escort'
require 'yaml'
require 'json'
require 'logger'

module PDQTest
  class Puppet

    #
    # platform paths
    #
    CONTAINER_PATHS = {
        :windows => {
            :hiera_yaml => 'C:\\ProgramData\\PuppetLabs\\puppet\\etc\\hiera.yaml',
            :hiera_dir  => 'C:\\spec\\fixtures\\hieradata',
            :module_dir => 'C:\\ProgramData\\PuppetLabs\\code\\modules',
            :facts_dir  => 'C:\\ProgramData\\PuppetLabs\\facter\\facts.d',
        },
        :linux => {
            :hiera_yaml => '/etc/puppetlabs/puppet/hiera.yaml',
            :yum_cache  => "/var/cache/yum",
            :hiera_dir  => '/spec/fixtures/hieradata',
            :module_dir => '/etc/puppetlabs/code/modules',
            :facts_dir  => '/etc/puppetlabs/facter/facts.d',
        }
    }

    # path for common things on the *host* computer running pdqtest (vm, laptop, etc)
    HOST_PATHS = {
        :windows => {
            :hiera_yaml    => 'spec\\fixtures\\hiera.yaml',
            :hiera_dir     => 'spec\\fixtures\\hieradata',
            :default_facts => 'spec\\default_facts.yml',
        },
        :linux => {
            :hiera_yaml    => 'spec/fixtures/hiera.yaml',
            :hiera_dir     => 'spec/fixtures/hieradata',
            :default_facts => 'spec/default_facts.yml',
        }
    }


    SETTINGS = {
        :windows => {
            :magic_marker    => '@PDQTestWin',
            :setup_suffix    => '__setup.ps1',
            :before_suffix   => '__before.pats',
            :after_suffix    => '.pats',
            :magic_marker_re => /#\s*@PDQTestWin\s$*/,
            :name            => "pats",
            :test_cmd        => "pats.ps1",
            :puppet          => "puppet.bat",
        },
        :linux => {
            :magic_marker    => '@PDQTest',
            :setup_suffix    => '__setup.sh',
            :before_suffix   =>'__before.bats',
            :after_suffix    => '.bats',
            :magic_marker_re => /#\s*@PDQTest\s$*/,
            :name            => "bats",
            :test_cmd        => "bats",
            :puppet          => "puppet",
        },
    }

    #
    # statics
    #
    XATS_TESTS        = Util.joinp('spec', 'acceptance')
    EXAMPLES_DIR      = 'examples'
    MANIFESTS_DIR     = 'manifests'
    CLASS_RE          = /^class /
    FIXTURES          = '.fixtures.yml'
    TMP_PUPPETFILE    = '.Puppetfile.pdqtest'
    METADATA          = 'metadata.json'


    #
    # state
    #
    @@bats_executed   = []
    @@setup_executed  = []
    @@skip_second_run = false

    def self.cp(key)
      CONTAINER_PATHS[Util.host_platform][key] ||
          raise("missing variable CONTAINER_PATHS[#{Util.host_platform}][#{key}]")
    end

    def self.hp(key)
      HOST_PATHS[Util.host_platform][key] ||
          raise("missing variable HOST_PATHS[#{Util.host_platform}][#{key}]")
    end

    def self.setting(key)
      SETTINGS[Util.host_platform][key] ||
          raise("missing variable SETTINGS[#{Util.host_platform}][#{key}]")
    end

    def self.skip_second_run(skip_second_run)
      @@skip_second_run = skip_second_run
    end

    def self.reset_bats_executed
      @@bats_executed = []
    end

    def self.reset_setup_executed
      @@setup_executed = []
    end

    def self.get_bats_executed
      @@bats_executed
    end

    def self.get_setup_executed
      @@setup_executed
    end

    def self.module_metadata
      if File.exist? METADATA
        file = File.read(METADATA)
        JSON.parse(file)
      else
        raise("Puppet metadata not found at #{METADATA} - not a valid puppet module")
      end
    end

    def self.save_module_metadata(metadata)
      File.open(METADATA,"w") do |f|
        f.write(JSON.pretty_generate(metadata))
      end
    end

    def self.module_name
      module_metadata['name'].split(/[\/-]/)[1]
    end

    def self.os_support
      module_metadata['operatingsystem_support'] || []
    end



    # Regenerate .fixtures.yml from metadata
    # https://github.com/puppetlabs/puppetlabs_spec_helper#using-fixtures
    # The format looks like this:
    #
    # ```
    #   fixtures:
    #     forge_modules:
    #       stdlib:
    #         repo: "puppetlabs/stdlib"
    #         ref: "2.6.0"
    #
    # Note that ref doesn't accept a range like metadata.json does, but then
    # r10k doesn't follow dependencies anyway so may as well just code a static
    # known good working version in it and not worry ---> use a known good
    # version for testing, not a range `metadata.json`
    def self.fixtures_yml
      fixtures = {
          "fixtures" => {
              "forge_modules" => {}
          }
      }
      module_metadata["dependencies"].each do |dep|
          forge_name  = dep["name"]
          puppet_name = dep["name"].split("-")[1]
          ref         = dep["version_requirement"]

          fixtures["fixtures"]["forge_modules"][puppet_name] = {
            "repo" => forge_name,
            "ref"  => ref,
          }
      end

      # now we have our list of fixtures from `metadata.json`, merge it with any
      # exiting .fixtures.yml content to preserve any git fixtures that may have
      # been added manually. Clobber/update any existing content that is NOT
      # from `metadata.json` while preserving things that are from git. If we
      # have ended up declaring different versions of the same module then its
      # up to user's to resolve this by removing the dependency from either
      # `metadata.json` or `.fixtures.yml`. You shouldn't be depending on git
      # resources in `metadata.json` anyway so this shoudln't be an issue
      if File.exist?(FIXTURES)
        existing_fixtures = YAML.load_file(FIXTURES)
        existing_fixtures.deep_merge(fixtures)
        fixtures = existing_fixtures
      end

      File.open(FIXTURES, 'w') { |f| YAML.dump(fixtures, f) }
    end

    def self.class2filename(c)
      if c == module_name
        f = "#{MANIFESTS_DIR}#{File::ALT_SEPARATOR||File::SEPARATOR}init.pp"
      else
        f = c.gsub(module_name, MANIFESTS_DIR).gsub('::', (File::ALT_SEPARATOR||File::SEPARATOR)) + '.pp'
      end

      f
    end

    def self.filename2class(f)
      # strip any leading `./`
      f.sub!(/^\.\//,'')

      if f == "#{MANIFESTS_DIR}#{File::ALT_SEPARATOR||File::SEPARATOR}init.pp"
        c = module_name
      else
        c = f.gsub(MANIFESTS_DIR, "#{module_name}").gsub(File::ALT_SEPARATOR||File::SEPARATOR, '::').gsub('.pp','')
      end

      c
    end

    def self.find_examples()
      examples = []
      if Dir.exists?(EXAMPLES_DIR)
        Find.find(EXAMPLES_DIR) do |e|
          if ! File.directory?(e) && ! File.readlines(e).grep(setting(:magic_marker_re)).empty?
            examples << e
          end
        end
      end
      $logger.info "examples to run" + examples.to_s
      examples
    end

    # process fixtures->repositories->* from fixtures.yml if present to
    # generate an array of commands to run ON THE DOCKER VM to checkout the
    # required modules from git
    def self.git_fixtures()
      refresh_cmd = []
      if File.exists?(FIXTURES)
        fixtures = YAML.load_file(FIXTURES)
        if fixtures.has_key?('repositories')
          fixtures['repositories'].each { |fixture, opts|
            target = "spec/fixtures/modules/#{fixture}"
            if opts.instance_of?(String)
              source = opts
              ref    = 'master'
            elsif opts.instance_of?(Hash)
              source = opts['repo']
              if opts.has_key? 'ref'
                ref = opts['ref']
              else
                ref = 'master'
              end
            end

            refresh_cmd << "git_refresh refresh --target-dir #{target} --source-url #{source} --ref #{ref}"
          }
        end
      end

      refresh_cmd
    end

    # find the available classes in this module
    def self.find_classes()
      mod_name = module_name
      classes = []
      if Dir.exists?(MANIFESTS_DIR)
        Find.find(MANIFESTS_DIR) do |m|
          if m =~ /\.pp$/
            # check the file contains a valid class
            if ! File.readlines(m).grep(CLASS_RE).empty?
              # Class detected, work out class name and add to list of found classes
              classes << filename2class(m)
            else
              $logger.info "no puppet class found in #{m}"
            end
          end
        end
      end

      classes
    end

    def self.test_basename(t)
      # remove any leading `./`
      t.sub!(/^\.\//, '')
      # remove examples/ and .pp
      # eg ./examples/apache/mod/mod_php.pp --> apache/mod/mod_php
      t.gsub(EXAMPLES_DIR + '/','').gsub('.pp','')
    end

    def self.xats_test(container, example, suffix)
      testcase = Util.joinp(XATS_TESTS, test_basename(example) + suffix)
      if File.exists?(testcase)
        $logger.info "*** #{setting(:name)} test **** #{setting(:test_cmd)} #{testcase}"
        res = PDQTest::Docker.exec(container, "cd #{Docker.test_dir} ; #{setting(:test_cmd)} #{testcase}")
        status = PDQTest::Docker.exec_status(res)
        PDQTest::Docker.log_out(res)
        @@bats_executed << testcase
      else
        $logger.info "no #{suffix} tests for #{example} (should be at #{testcase})"
        status = true
      end

      status
    end

    def self.setup_test(container, example)
      setup_script = Util.joinp(XATS_TESTS, test_basename(example)) + setting(:setup_suffix)
      if File.exists?(setup_script)
        script = File.read(setup_script)

        if script =~ /^\s*$/
          $logger.info "skipping empty setup script at #{setup_script}"
        else
          $logger.info "Setting up test for #{example}"

          res = PDQTest::Docker.exec(container, script)
          status = PDQTest::Docker.exec_status(res)
          PDQTest::Docker.log_out(res)
        end
        @@setup_executed << setup_script
      else
        $logger.info "no setup file for #{example} (should be in #{setup_script})"
        status = true
      end

      status
    end

    def self.run_example(container, example)
      $logger.info "testing #{example}"
      status = false

      if setup_test(container, example)

        # see if we should run a bats test before running puppet
        if xats_test(container, example, setting(:before_suffix))

          # run puppet apply - 1st run
          res = PDQTest::Docker.exec(container, puppet_apply(example))
          PDQTest::Docker.log_out(res)
          if PDQTest::Docker.exec_status(res, true) # allow 2 as exit status

            if @@skip_second_run
              $logger.info "Skipping idempotency check as you requested..."

              # check the system right now since puppet ran OK once
              status = xats_test(container, example, setting(:after_suffix))
            else
              # run puppet apply - 2nd run (check for idempotencey/no more changes)
              res = PDQTest::Docker.exec(container, puppet_apply(example))
              PDQTest::Docker.log_out(res)

              # run the bats test if nothing failed yet
              if PDQTest::Docker.exec_status(res) # only allow 0 as exit status
                status = xats_test(container, example, setting(:after_suffix))
              else
                $logger.error "Not idempotent: #{example}"
              end
            end
          else
            $logger.error "First puppet run of #{example} failed (status: #{res[Docker::STATUS]})"
          end
        else
          $logger.error "#{setting(:name)} tests to run before #{example} failed (status: #{res[Docker::STATUS]})"
        end
      else
        $logger.error "Setup script for #{example} failed (see previous error)"
      end

      status
    end

    def self.run(container, example=nil)
      # we must always have ./spec/fixtures/modules because we need to create a
      # symlink back to the main module inside here...
      # (spec/fixtures/modules/foo -> /testcase)
      if ! Dir.exists?('spec/fixtures/modules')
        $logger.info
          "creating empty spec/fixtures/modules, if you module fails to run due "
          "to missing dependencies run `make` or `pdqtest all` to retrieve them"
        FileUtils.mkdir_p('spec/fixtures/modules')
      end

      status = true
      $logger.info "...running container setup"
      setup_start = Time.now
      res = PDQTest::Docker.exec(container, setup)
      setup_end = Time.now
      status &= PDQTest::Docker.exec_status(res)
      if Util.is_windows
        # write a script to allow user to update modules
        $logger.info "wasted #{((setup_end - setup_start))} seconds of your life on windows tax"
        File.open("refresh.ps1", 'w') do |file|
          res[Docker::REAL_CMD].each do |c|
            file.puts("#{c[0]} #{c[1]} \"#{c[2]}\"")
          end
        end
        Emoji.emoji_message(
            :shame,
            "run refresh.ps1 to update container after changing files on host!",
            ::Logger::WARN)
      end
      if status
          $logger.info "...run tests"
          if example
            status &= run_example(container, example)
            if ! status
              $logger.error "Example #{example} failed!"
            end
          else
            find_examples.each { |e|
              if status
                status &= run_example(container, e)
                if ! status
                  $logger.error "Example #{e} failed! - skipping rest of tests"
                end
              end
            }
          end
      else
        PDQTest::Docker.log_all(res)
        $logger.error "Error running puppet setup, see previous error, command was: #{res[Docker::REAL_CMD]}"
      end

      PDQTest::Emoji.partial_status(status, 'Puppet')
      status
    end


    def self.puppet_apply(example)
      "cd #{Docker.test_dir} ; #{setting(:puppet)} apply --detailed-exitcodes #{example}"
    end

    def self.info
      $logger.info "Parsed module name: #{module_name}"
    end

    # extract a Puppetfile from metadata.json and install modules using r10k
    def self.install_modules()
      json = JSON.parse(File.read(METADATA))
      puppetfile = []
      if json.has_key?("dependencies")
        json["dependencies"].each { |dependency|
          line = "mod '#{dependency['name']}'"
          if dependency.has_key?("version_requirement")
            # R10K supports specifc named version or 'latest', not the rich versions defined in metadata. To make this
            # work we will drop any version that specifies a range and just install the latest
            if dependency['version_requirement'].match?(/^\d/)
              line += ", '#{dependency['version_requirement']}'"
            end
          end
          puppetfile << line
        }
      end

      File.open(TMP_PUPPETFILE, "w") do |f|
        f.puts(puppetfile)
      end

      PDQTest::Emoji.emoji_message(:slow, "I'm downloading The Internet, please hold...")

      cmd = "bundle exec r10k puppetfile install --verbose --moduledir ./spec/fixtures/modules --puppetfile #{TMP_PUPPETFILE}"
      status = system(cmd)

      if ! status
        $logger.error "Failed to run the R10K command: #{cmd}"
      end

      status
    end

    def self.setup
      commands = []

      # link testcase module
      commands << Util.mk_link(
          Util.joinp(cp(:module_dir), module_name),
          PDQTest::Docker.test_dir
      )


      # link dependency modules
      sfm = Util.joinp("spec", "fixtures", "modules")

      Dir.entries(sfm).select { |entry|
        File.directory?(Util.joinp(sfm, entry)) && !(entry =='.' || entry == '..')
      }.reject { |entry|
        # do not copy the symlink of ourself (pdk creates it)
        entry == module_name
      }.each { |entry|
        commands << Util.mk_link(
            Util.joinp(cp(:module_dir), entry),
            Util.joinp(PDQTest::Docker.test_dir, sfm, entry)
        )
      }


      # link hieradata
      if Dir.exist? hp(:hiera_dir)
        commands << Util.mk_link(
            cp(:hiera_dir),
            Util.joinp(Docker.test_dir, hp(:hiera_dir))
        )
      end

      # link hiera.yaml
      if File.exist? hp(:hiera_yaml)
        commands << Util.mk_link(
            cp(:hiera_yaml),
            Util.joinp(Docker.test_dir, hp(:hiera_yaml))
        )
      end

      # link external facts
      commands << Util.mk_link(
          Util.joinp(cp(:facts_dir), File.basename(hp(:default_facts))),
          Util.joinp(Docker.test_dir, hp(:default_facts))
      )
      commands

    end
  end
end
