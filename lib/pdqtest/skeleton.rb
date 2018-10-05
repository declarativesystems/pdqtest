require 'fileutils'
require 'digest'
require 'pdqtest/puppet'
require 'pdqtest/version'
require 'pdqtest/util'
require 'pdqtest/upgrade'
require 'pdqtest/pdqtest1x'
require 'pdqtest/pdk'
require 'erb'

module PDQTest
  module Skeleton

    TEMP_PDK_MODULE  = "x"
    FIXTURES         = '.fixtures.yml'
    SPEC_DIR         = 'spec'
    ACCEPTANCE_DIR   = File.join(SPEC_DIR, 'acceptance')
    SKELETON_DIR     = 'skeleton'
    EXAMPLES_DIR     = 'examples'
    HIERA_DIR        = File.join(SPEC_DIR, 'fixtures', 'hieradata')
    HIERA_YAML       = 'hiera.yaml'
    HIERA_TEST       = 'test.yaml'
    PDK_FILES        = [
        "spec/spec_helper.rb",
        "spec/default_facts.yml",
        ".pdkignore",
        "Gemfile",
        "Rakefile",
        ".gitignore",
        ".gitattributes",
    ]

    # PDK adds custom metadata fields which we can ONLY get by creating a new
    # module. We already do this so stash the details here when we have them
    @@pdk_metadata = {}

    # Every time we `pdqtest upgrade`, update .sync.yml (merges)
    SYNC_YML_CONTENT = {
        ".travis.yml" => {
            "unmanaged" => true,
        },
        "bitbucket-pipelines.yml" => {
            "unmanaged" => true,
        },
        "appveyor.yml" => {
            "unmanaged" => true,
        },
        ".gitignore" => {
            "paths" => [
                ".Puppetfile.pdqtest",
                "refresh.ps1",
            ],
        },
        ".gitattributes" => {
            "include" => [
                "*.epp eol=lf",
                "*.json eol=lf",
                "*.yaml eol=lf",
                "*.yml eol=lf",
                "*.md eol=lf",
            ]
        }
    }.freeze


    def self.should_replace_file(target, skeleton)
      target_hash   = Digest::SHA256.file target
      skeleton_hash = Digest::SHA256.file skeleton

      should = (target_hash != skeleton_hash)
      $logger.debug "should replace: #{should}"

      should
    end

    def self.install_skeletons
      FileUtils.cp_r(Util.resource_path(File.join(SKELETON_DIR) + "/."), ".")
    end


    def self.install_skeleton(target_file, skeleton, replace=true)
      skeleton_file = Util.resource_path(File.join(SKELETON_DIR, skeleton))
      install = false
      if File.exists?(target_file)
        if replace && should_replace_file(target_file, skeleton_file)
          install = true
        else
          $logger.debug "#{target_file} exists and will not be replaced"
        end
      else
        install = true
      end
      if install
        $logger.debug "Installing skeleton file at #{target_file}"
        FileUtils.cp(skeleton_file, target_file)
      end
    end

    # vars is a hash of variables that can be accessed in template
    def self.install_template(target, template_file, vars)
      if ! File.exists?(target)
        template = File.read(Util::resource_path(File.join('templates', template_file)))
        content  = ERB.new(template, nil, '-').result(binding)
        File.write(target, content)
      end
    end

    def self.install_gemfile_project
      install_skeleton(GEMFILE, GEMFILE)

      # upgrade the gemfile to *this* version of pdqtest + puppet-strings
      Upgrade.upgrade()
    end

    def self.directory_structure
      FileUtils.mkdir_p(ACCEPTANCE_DIR)
      FileUtils.mkdir_p(EXAMPLES_DIR)
      FileUtils.mkdir_p(HIERA_DIR)
    end

    def self.init
      directory_structure

      install_pdk_skeletons
      install_skeletons
      install_acceptance
      Upgrade.upgrade()

      # the very _last_ thing we do is enable PDK in metadata. Once this switch
      # is set, we never touch the files in PDK_FILES again
      PDQTest::Pdk.enable_pdk(@@pdk_metadata)
    end

    # on upgrade, do a more limited skeleton copy - just our own integration
    # points
    def self.upgrade
      install_skeleton('Makefile', 'Makefile')
      install_skeleton('make.ps1', 'make.ps1')
      install_skeleton('bitbucket-pipelines.yml', 'bitbucket-pipelines.yml')
      install_skeleton('.travis.yml', '.travis.yml')
      install_skeleton('appveyor.yml', 'appveyor.yml')
      install_skeleton('.ci_custom.sh', '.ci_custom.sh', false)
      Pdk.amend_sync_yml(SYNC_YML_CONTENT)
    end

    def self.install_acceptance(example_file ="init.pp")
      directory_structure

      example_name = File.basename(example_file).gsub(/\.pp$/, '')
      install_template("#{EXAMPLES_DIR}/#{File.basename(example_file)}",'examples_init.pp.erb', {})

      install_skeleton(File.join('spec', 'acceptance', "#{example_name}.bats"), '../acceptance/init.bats', false)
      install_skeleton(File.join('spec', 'acceptance', "#{example_name}__before.bats"), '../acceptance/init__before.bats', false)
      install_skeleton(File.join('spec', 'acceptance', "#{example_name}__setup.sh"), '../acceptance/init__setup.sh', false)
    end

    # Scan the examples directory and create a set of acceptance tests. If a
    # specific file is given as `example` then only the listed example will be
    # processed (and it will be created if missing).  If files already exist, they
    # will not be touched
    def self.generate_acceptance(example=nil)
      examples = []
      if example
        # specific file only
        examples << example
      else
        # Each .pp file in /examples (don't worry about magic markers yet, user
        # will be told on execution if no testscases are present as a reminder to
        # add it
        examples += Dir["examples/*.pp"]
      end

      examples.each { |e|
        install_acceptance(e)
      }
    end


    def self.install_pdk_skeletons

      if ! PDQTest::Pdk.is_pdk_enabled
        $logger.info "Doing one-time upgrade to PDK - Generating fresh set of files..."
        project_dir = File.expand_path Dir.pwd
        Dir.mktmpdir do |tmpdir|
          Dir.chdir(tmpdir) do
            status = PDQTest::Pdk.run("new module #{TEMP_PDK_MODULE} --skip-interview")

            if status
              # snag generated metadata now we are in the temporary module dir
              Dir.chdir TEMP_PDK_MODULE do
                @@pdk_metadata = PDQTest::Puppet.module_metadata

                # Now we need to install .sync.yml and re-install otherwise not
                # applied until `pdk update`
                PDQTest::Pdk.amend_sync_yml(SYNC_YML_CONTENT)

                # Next do a forced update to make PDK process sync.yml
                PDQTest::Pdk.run("update --force")
              end

              PDK_FILES.each do |pdk_file|
                upstream_file = File.join(tmpdir, TEMP_PDK_MODULE, pdk_file)

                # check if we are trying to install a file from PDQTest or have
                # some random/customised file in place
                Dir.chdir project_dir do
                  if PDQTest1x.was_pdqtest_file(pdk_file)
                    if ! File.exists?(pdk_file) || PDQTest1x.is_pdqtest_file(pdk_file)
                      # overwrite missing or PDQTest 1x files
                      install = true
                    else
                      raise(<<~END)
                        Detected an unknown/customised file at
                          #{pdk_file}
                        Please see the PDQTest 1x->2x upgrade guide at
                        https://github.com/declarativesystems/pdqtest/blob/master/doc/upgrading.md
    
                        If your sure you don't want this file any more, move it out
                        of the way and re-run the previous command
                      END
                    end
                  else
                    install = true
                  end

                  if install
                    $logger.info("Detected PDQTest 1.x file at #{pdk_file} (will upgrade to PDK)")
                    FileUtils.cp(upstream_file, pdk_file)
                  end
                end
              end
            else
              raise("error running PDK - unable to init")
            end
          end
        end
      else
        $logger.debug "PDK already enabled, no skeletons needed"
      end
    end
  end
end
