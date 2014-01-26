FROM ubuntu:12.04

# Update base image
RUN echo deb http://us.archive.ubuntu.com/ubuntu/ precise universe >> /etc/apt/sources.list;\
  echo deb http://us.archive.ubuntu.com/ubuntu/ precise-updates main restricted universe >> /etc/apt/sources.list;\
  echo deb http://security.ubuntu.com/ubuntu precise-security main restricted universe >> /etc/apt/sources.list;\
  echo initscripts hold | dpkg --set-selections;\
  echo upstart hold | dpkg --set-selections;\
  echo udev hold | dpkg --set-selections;\
  apt-get update;\
  apt-get -y upgrade;\
  apt-get clean

# Install packages
RUN apt-get install -y build-essential git curl sudo;\
  apt-get clean

# Install Chef Solo
RUN cd /tmp;\
  curl -LO https://www.opscode.com/chef/install.sh && sudo bash ./install.sh -v 11.4.4;\
  /opt/chef/embedded/bin/gem install berkshelf --no-ri --no-rdoc;\
  git clone https://gitlab.com/gitlab-org/cookbook-gitlab.git;\
  cd /tmp/cookbook-gitlab;\
  /opt/chef/embedded/bin/berks install --path /tmp/cookbooks

# Inject config
ADD . /build

# Run Chef
RUN chef-solo -c /build/solo.rb -j /build/solo.json;\
  apt-get clean

EXPOSE 80
EXPOSE 22
