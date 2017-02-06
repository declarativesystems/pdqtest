module PDQTest
  module Lint
    LINT_PATHS = [
      "manifests"
    ]

    LINT_OPTIONS = [
      "--relative",
      "--fail-on-warnings",
      "--no-double_quoted_strings-check",
      "--no-80chars-check",
      "--no-variable_scope-check",
      "--no-quoted_booleans-check",
    ]
    def self.puppet
      status = true
      LINT_PATHS.each { |p|
        if Dir.exists?(p)
          if ! system("puppet-lint #{LINT_OPTIONS.join ' '} manifests")
            status = false
          end
        end
      }

      status
    end

  end
end
