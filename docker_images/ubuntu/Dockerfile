FROM ubuntu:xenial-20180228

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install systemd && apt-get clean && \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/sbin/init"]


# leave the apt metadata in place to allow apt-get install... to work (puppet
# package resource)
RUN apt-get update && apt-get install -y cron \
    initscripts \
    git \
    zlib1g-dev \
    debianutils \
    libgpm-dev \
    policycoreutils \
    curl \
    locales \
    iputils-ping \
    dnsutils \
    locales-all && dpkg-reconfigure locales

# fix locale
RUN echo 'LANG=en_US.UTF-8' > /etc/locale.conf
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PATH /usr/local/bats/bin:/opt/puppetlabs/puppet/bin/:/usr/sbin:/sbin:/usr/bin:/bin
ENV TERM xterm

# puppet (and dont run the daemons)
RUN curl -Lo /tmp/puppet-agent.deb https://pm.puppet.com/puppet-agent/2017.3.5/5.3.5/repos/deb/xenial/PC1/puppet-agent_5.3.5-1xenial_amd64.deb && \
    dpkg -i /tmp/puppet-agent.deb && rm /tmp/puppet-agent.deb && \
  /opt/puppetlabs/puppet/bin/puppet --version && \
  /opt/puppetlabs/puppet/bin/facter --version && \
  systemctl disable puppet && \
  systemctl disable mcollective

# bats
RUN git clone https://github.com/bats-core/bats-core /usr/local/bats

# librarian
RUN /opt/puppetlabs/puppet/bin/gem install librarian-puppet

# git refresh (for processing .fixtures.yml git modules)
RUN /opt/puppetlabs/puppet/bin/gem install git_refresh

# testcase (our module)
RUN mkdir /testcase
VOLUME /testcase

# alternate shudown for systemd
STOPSIGNAL SIGRTMIN+3
