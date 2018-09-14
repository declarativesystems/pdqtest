# Windows
PDQTest now supports windows

## Requirements
* Windows 10
* VTx enabled in UEFI
* HyperV feature installed
* Docker for Windows installed and [windows containers enabled](https://docs.docker.com/docker-for-windows/#switch-between-windows-and-linux-containers)
* [Docker API port enabled for localhost access](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-docker/configure-docker-daemon)
```puppet
    "hosts": ["tcp://127.0.0.1:2375"]
```
* Enable windows OS acceptance tests in `metadata.json`:
```json
  "operatingsystem_support": [
    {
      "operatingsystem":"windows"
    }
  ],
```
* (probably) newer version of ruby (2.5.1) - install with `choco install ruby`

## Warnings/Notes
* The docker volume doesn't play nice with puppet/ruby (breaks whole app if 
  `/lib` directory present, so we have to _copy_ the files into the container
  this is of course very slow. Also you must run `refresh.ps1` inside the 
  container to refresh the files if your doing TDD on your main workstation.
* Run `pdqtest` from a `Powershell ISE` not `cmd.exe` or `powershell`
* Run `[console]::OutputEncoding=[Text.Encoding]::UTF8` to fix emojis 
  (`Powershell ISE` only)
* Otherwise run with `--disable-emoji` for other terminals
* Keep an eye on how many windows containers are running `docker ps` - things
  seem to choke up if you have more then a handful


## FAQ
How do I get a shell?

_Start a new container_
```shell
docker run declarativesystems/windows-XXX cmd
```

_Enter a running container_
```shell
docker run -ti XXX cmd
```

what's going on with `.bat` files?

They seem to work but you need to pass the full filename to docker run, eg:

```shell
docker exec ... foo.bat
```

not

```shell
docker exec ... foo
```

My module refuses to be found or work! (class not found...)

Beats me.. Make sure you have a `depenedencies` 
section in `metadata.json` even if its empty or puppet seems to break

