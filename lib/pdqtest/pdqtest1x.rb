# Detection routines for PDQTest 1x files so that we can find and remove them
# as part of any PDQTest 2x/PDK upgrade
require 'digest/md5'

module PDQTest
  module PDQTest1x

    # Urgh... I wish I'd put my own magic marker in these files... then I would
    # have been able to find them easily(!)
    # This is a list of known PDQTest integrations and their MD5 sums.
    # Thankfully I didn't make _too many_ upgrades
    PDQTEST_FILES = {
        "Rakefile" => [
          "3c65c0650e68771854036fbe67fb0f5d",
          "0254db5d3fc38c67a2c160d7296a24f8"
        ],
        "spec/spec_helper.rb" => [
          "8862eca30ed66bc71c1acc7a0da89305",
          "0db89c9a486df193c0e40095422e19dc",
        ],
        ".rspec" => [
          "c5f206a3f2387663a941cd9719e4bb00"
        ]
    }

    # These plus the `pdqtest` gem are the _only_ gems that PDQTest 1x ever used
    # If we only see these gems and our own, then we are almost certainly safe
    # to replace the file with the PDK version
    # List was extracted with some awk-foo
    # https://gist.github.com/GeoffWilliams/21de190c5f6285b68f777885d92dba72
    PDQTEST_RUBYGEMS = [
      /gem 'CFPropertyList'/,
      /gem 'facter', '>= 1.7.0'/,
      /gem 'facter', '2.4.6'/,
      /gem 'facter', '2.5.1'/,
      /gem 'metadata-json-lint'/,
      /gem 'puppet'/,
      /gem 'puppetlabs_spec_helper', '>= 1.0.0'/,
      /gem 'puppet-lint', '>= 1.0.0'/,
      /gem 'puppet', puppetversion/,
      /gem 'puppet-strings'/,
      /gem 'rake', '~> 10.0'/,
      /gem 'rspec', '~> 2.0'/,
      /gem 'rspec-puppet'/,
      /gem 'rspec-puppet-facts', '1.7.0'/,
      /gem 'rubocop'/,
      /gem 'rubocop', '0.47.1'/,
      /gem 'rubocop', '0.50.0'/,
    ]

    PDQTEST_GEM = /^\s*gem 'pdqtest'/

    # Did PDQTest ever manage this file?
    def self.was_pdqtest_file(f)
      [
          ".rspec",
          "Gemfile",
          "Rakefile",
          "spec/fixtures",
      ].include? f
    end

    def self.is_pdqtest_file(f)
      detected = false

      if PDQTEST_FILES.include?(f)
        if File.exist? f
          # check for known PDQTest files spanning all versions
          project_md5 = Digest::MD5.file(f).hexdigest
          if PDQTEST_FILES[f].include?(project_md5)
            $logger.debug("File at #{f} matches a known PDQTest 1x file")
            detected = true
          end
        else
          $logger.debug "Missing PDQTest file #{f}"
          detected = false
        end
      elsif f == "Gemfile"
        if File.exist? f
          # to detect if PDQTest is the Gemfile, just look for the gem itself
          if File.readlines(f).grep(PDQTEST_GEM).any?
            # this project previously used PDQTest, now check to see if there
            # are any unknown gems in the file
            $logger.debug("Detected PDQTest 1.x in your Gemfile")
            detected = true
            project_gems = File.readlines(f).grep(/^\s*gem /)
            project_gems.reject { |line|
              line =~ PDQTEST_GEM
            }.each { |project_gem|
              found = false
              PDQTEST_RUBYGEMS.each { |pdqtest_gem|
                if project_gem =~ pdqtest_gem
                  $logger.debug "known gem detected: #{project_gem.strip}"
                  found = true
                end
              }
              if ! found
                $logger.error("unknown gem line in your Gemfile: '#{project_gem.strip}'")
                detected = false
              end
            }
          end
        else
          $logger.debug("missing Gemfile: #{f}")
          detected = false
        end
      else
        raise("File #{f} was never managed by PDQTest, why are you testing it?")
      end

      detected
    end

  end
end