# Caching
PDQTest will attempt to cache:
* Puppet modules (via r10k) in `~/.r10k/cache`
* The yum cache in `~/.pdqtest/cache/yum`

Note that since the yum cache is writen to via a docker volume from the 
container your running tests in, the files in this directory will be root owned.
If you need to clear your cache for whatever reason, delete the 
`~/.pdqtest/cache` directory (you will likely need `sudo`) and PDQtest will 
recreate it next time it runs.
