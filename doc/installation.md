# Installation
PDQTest runs on Linux/MAC and Windows systems, with the caveat that:
* Windows acceptance tests can only be run on Windows
* Linux acceptance tests can only run on Linux
If you are using Windows and want to test Linux modules, the easiest way for you
to run PDQTest is to install virtualisation software and then use 
[Vagrant](http://vagrantup.com/) to create a VM that shares a filesystem with 
your main Windows desktop.  This will allow you to edit your puppet code as you
please and have it instantly show up inside of a Linux VM where you can run
PDQTest and Docker.

**Do NOT run PDQTest on a managed Puppet node, you may damage the agent**

## Linux Instructions

1. Install Ruby - you will need a fairly new version of Ruby as Puppet requires
   this. On linux you will probably need development libraries, eg 
   `yum groupinstall 'Development Tools'`. Once ruby is installed follow any 
    additional setup steps to activate the environment and then check it really
    worked by running `ruby --version` before proceeding.  Note that `pdqtest` 
    should not be run as `root`. Easy ways to install an up-to-date Ruby:
    * [RVM](https://rvm.io/)
    * [RBENV](https://github.com/rbenv/rbenv)  
2. Make sure `git` is installed - `yum install git`
3. Install the [PDK OS package](https://puppet.com/docs/pdk/1.x/pdk_install.html)
4. Install PDQTest - `gem install pdqtest`
5. Install bundler (the only sane way to manage Ruby dependencies) 
   `gem install bundler`
7  Add PDK to your path (add to `.profile` for permanent): 
   `export PATH=/opt/puppetlabs/pdk/bin/:$PATH`
8. Install [Docker CE](www.docker.com)
9. Start the `docker` daemon and make sure the user your running as is in the
   `docker` group.  You will need to log out and back in again after doing this
10. Install the PDQTest docker images by typing `pdqtest setup`

## Mac instructions
**UNTESTED! Do you own a mac? Please let me know what works**

Instructions should be as Linux, but from memory, I had to run:

```shell
eval "$(docker-machine env default)"
```

to configure the shell last time I owned a mac. If things have moved on since
then, let me know what else is needed (possibly including a patch) 

## Windows Instructions

1. You will need Windows 10 (Windows 10 Enterprise, Professional, or Education)
   and the system your running on must enable 
   [VTx](https://en.wikipedia.org/wiki/X86_virtualization#Intel_virtualization_(VT-x))
   which is needed for 
   [Windows containers](https://docs.microsoft.com/en-us/virtualization/windowscontainers/quick-start/quick-start-windows-10)
   running under 
   [Hyper-V](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/) 
   which we use for testing:
    * Laptops/Desktops - enable VTx in BIOS/UEFI
    * VMs - You **must** run under VMWare and enable VTx in VM settings (as well
      as enabling on the host)
    * Make sure to allocate plenty of CPU and memory
    * Enable Hyper-V (The Hyper-V role cannot be installed on Windows 10 Home)
2. Install [Docker](http://docker.com/)
    * [Docker for Windows](https://docs.docker.com/docker-for-windows/install) 
      installed and 
      [windows containers enabled](https://docs.docker.com/docker-for-windows/#switch-between-windows-and-linux-containers)
    * [Docker API port enabled for localhost access](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-docker/configure-docker-daemon)
    ```json
    "hosts": ["tcp://127.0.0.1:2375"]
    ```
3. Install [Chocolatey](https://chocolatey.org/install)
4. Install Ruby 2.4 (Ruby 2.5 doesn't work yet 
   [PDK-1171](https://tickets.puppetlabs.com/browse/PDK-1171)): 
   `choco install ruby --version 2.4.3.1`
5. Install PDK: `choco install pdk`
6. Install bundler `gem install bundler`

**Be sure to read the [Windows notes](windows.md) for guidance on how to run 
tests on Windows**

