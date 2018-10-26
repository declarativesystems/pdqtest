# Windows
PDQTest now supports Windows! There are a few gotchas though and this support is
still experimental:

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
* The best way I can think of to work on the guest without going blind would be
  to share the folder _from the guest_ and mount it on the host, using Windows
  file-sharing

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

A:They seem to work but you need to pass the full filename to docker run (yes, 
`puppet` is actually `puppet.bat` on an installed system), eg:

```shell
docker exec XXX puppet.bat apply c:\testcase\examples\init.pp
```

not

```shell
docker exec XXX puppet
```
_where XXX is the ID of your container. Use `docker ps` to get a listing.


Q: I get `permission denied @ rb_sysopen` errors when running PDQTest but the
   files exist and I even gave ownership to `Everyone`

A: Ruby seems to be unable to read files that have the `hidden` attribute set.
   Remove the attribute from any files that are complained about.