# Installation
PDQTest only runs on Linux/MAC systems.  If you are using Windows, the easiest way for you to run PDQTest is to install virtualisation software and then use [Vagrant](http://vagrantup.com/) to create a VM that shares a filesystem with your main Windows desktop.  This will allow you to edit your puppet code as you please and have it instantly show up inside of a Linux VM where you can run PDQTest and Docker.

1. Install Ruby - you will need a fairly new version of Ruby as Puppet requires this.  [RVM](https://rvm.io/) or [RBENV](https://github.com/rbenv/rbenv) are easy ways of obtaining an up-to-date version.  Ruby 2.3 works prefectly.  You may need development libraries, eg `yum groupinstall 'Development Tools'` with these systems.  Once you have obtained a modern Ruby, follow any additional setup steps to activate the environment and then check it really worked by running `ruby --version` before proceeding.  Note that `pdqtest` should not be run as `root`.
2. Make sure `git` is installed - `yum install git`
3. Install the gem version of puppet - `gem install puppet`
4. Install PDQTest - `gem install pdqtest`
5. Install bundler (the only sane way to manage Ruby dependencies) - `gem install bundler`
6. Install [Docker CE](www.docker.com)
7. Start the `docker` daemon and make sure the user your running as is in the `docker` group.  You will need to log out and back in again after doing this
8. Install the [PDQTest Docker image](https://hub.docker.com/r/geoffwilliams/pdqtest-centos/) by typing `pdqtest setup`

You have now installed PDQTest.  Steps 6-8 are only required if running acceptance testing but are highly recommended.

Note:  Do *NOT* run PDQTest on a managed Puppet node, you may damage the agent.
