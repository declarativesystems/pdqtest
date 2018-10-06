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
ENV PATH /usr/local/bats/bin:/usr/sbin:/sbin:/usr/bin:/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/pdk/bin
ENV TERM xterm

# puppet (and dont run the daemons)
RUN curl -Lo /tmp/puppet-agent.deb https://pm.puppet.com/puppet-agent/2018.1.4/5.5.6/repos/deb/xenial/puppet5/puppet-agent_5.5.6-1xenial_amd64.deb && \
    dpkg -i /tmp/puppet-agent.deb && rm /tmp/puppet-agent.deb && \
  /opt/puppetlabs/puppet/bin/puppet --version && \
  /opt/puppetlabs/puppet/bin/facter --version && \
  systemctl disable puppet && \
  systemctl disable mcollective

# bats
RUN git clone https://github.com/bats-core/bats-core /usr/local/bats

# librarian
RUN /opt/puppetlabs/puppet/bin/gem install r10k

# testcase (our module)
RUN mkdir /testcase
VOLUME /testcase

# hiera
RUN mkdir -p /spec/fixtures/

# PDK
RUN curl -O https://apt.puppetlabs.com/puppet5-release-trusty.deb && \
    dpkg -i puppet5-release-trusty.deb && \
    apt-get update && \
    apt install -y pdk

# ruby
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN echo "source /etc/profile.d/rvm.sh" >> ~/.bashrc
RUN /bin/bash -c "source /etc/profile.d/rvm.sh ; rvm install 2.4.1"
RUN /bin/bash -c "source /etc/profile.d/rvm.sh ; gem install bundler ; bundle --version"

# alternate shudown for systemd
STOPSIGNAL SIGRTMIN+3
