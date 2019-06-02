FROM ubuntu:18.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    openssh-server \
    less \
    vim \
    git \
    python3.6 \
    python3-pip

# Install Node.JS
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && apt-get install -y --no-install-recommends \
  nodejs

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
   && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update \
   && apt-get install -y --no-install-recommends \
   yarn

RUN apt-get -qq clean autoclean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Change default python to python 3.6
RUN rm -f /usr/bin/python \
 && ln -s /usr/bin/python3.6 /usr/bin/python \
 && ln -s /usr/bin/pip3 /usr/bin/pip

RUN mkdir -p /var/run/sshd \
  && sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && sed -ri 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config \
  && mkdir -p $HOME/.ssh

RUN node --version \
  && yarn --version \
  && python --version \
  && pip --version

COPY entrypoint.sh /usr/local/bin/

WORKDIR /data
EXPOSE 22

ENTRYPOINT ["entrypoint.sh"]
CMD tail -f /dev/null
