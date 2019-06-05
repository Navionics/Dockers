FROM ubuntu:16.04

RUN apt-get -y update && apt-get -y install \
        build-essential \
        git openssl libreadline6 libreadline6-dev \
        git-core zlib1g zlib1g-dev libssl-dev \
        libyaml-dev libsqlite3-dev sqlite3 libxml2-dev \
        libxslt-dev libmysqlclient-dev libpq-dev \
        imagemagick phantomjs libffi-dev autoconf software-properties-common \
    && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
    && apt-get update \
    && apt-get install -y vim curl zip g++-4.9 nodejs \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 20

## Install ruby 2.1.2
RUN curl -L  http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz > ruby-2.1.2.tar.gz &&\
    tar -xvzf ruby-2.1.2.tar.gz &&\
    rm ruby-2.1.2.tar.gz &&\
    cd ruby-2.1.2/ &&\
    ./configure --prefix=/usr/local --enable-shared &&\
    make &&\
    make install

# Install  base gems
RUN gem install bundler -v 1.17.3 && \
    gem install "rubygems-update:<3.0.0" --no-document && \
    gem install rubygems-bundler rice rake-compiler --no-rdoc --no-ri

ENTRYPOINT ["/bin/bash"]
