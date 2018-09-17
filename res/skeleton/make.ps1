param(
    $target = "all"
)


switch ($target) {
    "all" {
	    bundle exec pdqtest all
    }
    "fast" {
	    bundle exec pdqtest fast
    }
    "shell" {
	    bundle exec pdqtest --keep-container acceptance
    }
    "shellnopuppet" {
	    bundle exec pdqtest shell
    }
    "logical" {
	    bundle exec pdqtest syntax
	    bundle exec pdqtest rspec
    }
    default {
        Write-Error "No such target: $($target)"
    }
}