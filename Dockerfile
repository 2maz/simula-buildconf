FROM ubuntu:22.04

MAINTAINER 2maz "https://github.com/2maz"

ARG PKG_BRANCH=main
RUN echo "Building for branch: $PKG_BRANCH"

RUN apt update
RUN apt upgrade -y

RUN export DEBIAN_FRONTEND=noninteractive; apt install -y ruby ruby-dev wget tzdata locales g++ autotools-dev make cmake sudo git python3 pkg-config

ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en_US:en
RUN locale-gen $LANG

RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
RUN echo "Europe/Oslo" > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

RUN useradd -ms /bin/bash docker
RUN echo "docker ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER docker
WORKDIR /home/docker

ENV SHELL /bin/bash

RUN git config --global user.email "roehr@simula.no"
RUN git config --global user.name "Simula Buildconf CI"

RUN mkdir -p /home/docker/autoproj-workspace
WORKDIR /home/docker/autoproj-workspace

RUN wget https://raw.githubusercontent.com/2maz/simula-buildconf/main/bootstrap.sh
COPY --chown=docker .ci/autoproj-config.yml seed-config.yml

ENV AUTOPROJ_BOOTSTRAP_IGNORE_NONEMPTY_DIR 1
ENV AUTOPROJ_NONINTERACTIVE 1

RUN chmod +x bootstrap.sh
RUN /bin/bash bootstrap.sh --seed-config=seed-config.yml
RUN /bin/bash -c "source env.sh; autoproj update; autoproj osdeps"
RUN /bin/bash -c "source env.sh; amake"

