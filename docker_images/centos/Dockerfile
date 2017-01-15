# Install all the RPM packages that puppet will install and disable
# metadata updates so that the environment can be joined to puppet
# and run without error in an offline environment
FROM picoded/centos-systemd:latest
MAINTAINER Geoff Williams <geoff.williams@puppet.com>
RUN \
  yum clean all && \
  yum update -y
RUN \
  yum groupinstall -y "Development Tools" && \
  yum install -y cronie \
    initscripts \
    git \
    zlib-devel \
    which \
    gpm-libs \
    policycoreutils \
    policycoreutils-restorecond \
    tputs && \
  echo "metadata_expire=never" >> /etc/yum.conf && \
  echo "LANG=C" >> /etc/environment && \
  echo "LC_ALL=C" >> /etc/environment && \
  echo "export PATH=/usr/local/bats/bin:/opt/puppetlabs/puppet/bin/:${PATH}" >> /etc/profile.d/zz_docker_puppet.sh && \
  echo "export TERM=xterm"  >> /etc/profile.d/zz_docker_puppet.sh && \
  chmod +x /etc/profile.d/zz_docker_puppet.sh && \
  echo "metadata_expire=never" >> /etc/yum.conf

# puppet
RUN yum -y install http://yum.puppetlabs.com/el/7/PC1/x86_64/puppet-agent-1.8.2-1.el7.x86_64.rpm && \
  /opt/puppetlabs/puppet/bin/puppet --version && \
  /opt/puppetlabs/puppet/bin/facter --version
:qdd
RUN git clone https://github.com/sstephenson/bats /usr/local/bats
RUN /opt/puppetlabs/puppet/bin/gem install librarian-puppet

# code under test
RUN mkdir /cut
VOLUME /cut

