# Windows
PDQTest now supports windows! There are a few gotchas though:

* The docker volume doesn't play nice with puppet/ruby: Whole app breaks if 
  `/lib` directory present, so we have to _copy_ the files into the container
  this is of course very slow. You must run `refresh.ps1` inside the container
  to refresh the files if your doing TDD on your main workstation.
* You must run PDQTest from `powershell.exe` and NOT `PowerShell ISE` or you
  encounter [PDK-1168](https://tickets.puppetlabs.com/browse/PDK-1168)
* Keep an eye on how many windows containers are running `docker ps` - things
  seem to choke up if you have more then a handful
* You **must** develop your modules on your **guest** filesystem (eg not at 
  `c:\vagrant` if your running windows 10 in a VM on linux):
  [PDK-1169](https://tickets.puppetlabs.com/browse/PDK-1169)

## FAQ
Q: How do I just get a shell inside my container? 

A:
```shell
.\make shellnopuppet
```

Q: How do I see GUI apps that are running in my container?

A: Beats me. Maybe there's a way to do something with RDP? The idea of windows
containers seems to be to run CLI applications/services and interact with them
through powershell or over the network. If anyone has a better answer let me
know 

Q: what's going on with `.bat` files?

A:They seem to work but you need to pass the full filename to docker run, eg:

```shell
docker exec XXX foo.bat
```

not

```shell
docker exec XXX foo
```
_where XXX is the ID of your container. Use `docker ps` to get a listing.

Q: My module refuses to be found or work! (class not found...)

A: Beats me.. This came up during testing but I haven't investigated further. 
Make sure you have a `depenedencies` section in `metadata.json` even if its 
empty or puppet seems to break (unverified)

