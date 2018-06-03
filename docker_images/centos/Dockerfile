FROM centos:centos7.4.1708

# Systemd in docker - state of the art:
# https://hub.docker.com/_/centos/
ENV container docker

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

RUN yum install -y cronie \
    initscripts \
    git \
    zlib-devel \
    which \
    gpm-libs \
    policycoreutils \
    policycoreutils-restorecond && yum clean all
RUN echo "metadata_expire=never" >> /etc/yum.conf

# fix locale
RUN echo 'LANG=en_US.UTF-8' > /etc/locale.conf
RUN yum -y install glibc-common
# swallow errors
RUN localedef --quiet -v -c -i en_US -f UTF-8 en_US.UTF-8 || true


ENV LANG en_US.UTF-8
# && \
#  echo "LANG=C" >> /etc/environment && \
ENV LC_ALL en_US.UTF-8
#  echo "LC_ALL=C" >> /etc/environment && \
ENV PATH /usr/local/bats/bin:/opt/puppetlabs/puppet/bin/:/usr/sbin:/sbin:/usr/bin:/bin
#  echo "export PATH=/usr/local/bats/bin:/opt/puppetlabs/puppet/bin/:${PATH}" >> /etc/environment && \
ENV TERM xterm
#  echo "export TERM=xterm"  >> /etc/environment

# puppet
RUN yum -y install https://pm.puppet.com/puppet-agent/2017.3.5/5.3.5/repos/el/7/PC1/x86_64/puppet-agent-5.3.5-1.el7.x86_64.rpm && \
  /opt/puppetlabs/puppet/bin/puppet --version && \
  /opt/puppetlabs/puppet/bin/facter --version

# bats
RUN git clone https://github.com/bats-core/bats-core /usr/local/bats

# r10k
RUN /opt/puppetlabs/puppet/bin/gem install r10k

# git refresh (for processing .fixtures.yml git modules)
RUN /opt/puppetlabs/puppet/bin/gem install git_refresh

# testcase (our module)
RUN mkdir /testcase
VOLUME /testcase

# alternate shudown for systemd
STOPSIGNAL SIGRTMIN+3
