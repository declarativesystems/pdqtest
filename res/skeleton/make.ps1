<#
.SYNOPSIS
  Run PDQTest targets
.DESCRIPTION
  See the instructions at https://github.com/declarativesystems/pdqtest/blob/master/doc/running_tests.md
.EXAMPLE
  .\make.ps1 - Run the default testing target
.EXAMPLE
  .\make.ps1 XXX - run the XXX target
.PARAMETER target
  Test suite to run
#>
param(
    $target = "all"
)

$gfl = "Gemfile.local"
$gfp = "Gemfile.project"

# Relink Gemfile.local
# https://github.com/declarativesystems/pdqtest/blob/master/doc/pdk.md#why-are-the-launch-scripts-essentialhow-does-the-pdqtest-gem-load-itself
function Install-GemfileLocal {
  # on windows, symlinks dont work on vagrant fileshares, so just copy the 
  # file if needed
  if (Test-Path $gfl) {
    $gflMd5 = (Get-FileHash -Path $gfl -Algorithm MD5).Hash
    $gfpMd5 = (Get-FileHash -Path $gfp -Algorithm MD5).Hash
    if ($gflMd5 -eq $gfpMd5) {
      # OK - ready to launch
    } else {
      write-error "$($gfl) different content to $($gfp)! Move it out the way or move the content to $($gfp)"
    }
  } else {
    write-host "[(-_-)zzz] Copying $($gfp) to $($gfl) and running pdk bundle..."
    copy $gfp $gfl
    pdk bundle install
  }
}


switch ($target) {
    "all" {
      Install-GemfileLocal
	    bundle exec pdqtest all
    }
    "fast" {
      Install-GemfileLocal
	    bundle exec pdqtest fast
    }
    "shell" {
      Install-GemfileLocal
	    bundle exec pdqtest --keep-container acceptance
    }
    "shellnopuppet" {
      Install-GemfileLocal
	    bundle exec pdqtest shell
    }
    "logical" {
      Install-GemfileLocal
	    bundle exec pdqtest syntax
	    bundle exec pdqtest rspec
    }
    default {
        Write-Error "No such target: $($target)"
    }
}
