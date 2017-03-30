# Install all the RPM packages that puppet will install and disable
# metadata updates so that the environment can be joined to puppet
# and run without error in an offline environment
FROM centos:centos7

# from https://hub.docker.com/r/picoded/centos-systemd/ but switched
# to upstream centos to keep image size down
ENV container docker
RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs
RUN yum -y update; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

MAINTAINER Geoff Williams <geoff.williams@puppet.com>
RUN yum install -y cronie \
    initscripts \
    git \
    zlib-devel \
    which \
    gpm-libs \
    policycoreutils \
    policycoreutils-restorecond && yum clean all
RUN echo "metadata_expire=never" >> /etc/yum.conf && \
  echo "LANG=C" >> /etc/environment && \
  echo "LC_ALL=C" >> /etc/environment && \
  echo "export PATH=/usr/local/bats/bin:/opt/puppetlabs/puppet/bin/:${PATH}" >> /etc/environment && \
  echo "export TERM=xterm"  >> /etc/environment

# puppet
RUN yum -y install http://yum.puppetlabs.com/el/7/PC1/x86_64/puppet-agent-1.8.2-1.el7.x86_64.rpm && \
  /opt/puppetlabs/puppet/bin/puppet --version && \
  /opt/puppetlabs/puppet/bin/facter --version

# bats
RUN git clone https://github.com/sstephenson/bats /usr/local/bats

# librarian
RUN /opt/puppetlabs/puppet/bin/gem install librarian-puppet

# git refresh (for processing .fixtures.yml git modules)
RUN /opt/puppetlabs/puppet/bin/gem install git_refresh

# code under test
RUN mkdir /cut
VOLUME /cut
