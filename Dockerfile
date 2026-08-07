# syntax=docker/dockerfile:1

FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG TOOL_REFRESH=manual

# System and kernel-facing tools stay with the distro. The fast-moving,
# user-space tools listed below are installed with Homebrew.
RUN test -n "$TOOL_REFRESH" \
    && apt-get update \
    && apt-get install --yes --no-install-recommends \
        apt-file \
        bash-completion \
        build-essential \
        ca-certificates \
        curl \
        dnsutils \
        file \
        git \
        gosu \
        htop \
        iproute2 \
        iputils-ping \
        less \
        locales \
        lsof \
        man-db \
        mtr-tiny \
        nano \
        netcat-openbsd \
        nfs-common \
        openssh-client \
        procps \
        rsync \
        socat \
        strace \
        tcpdump \
        telnet \
        traceroute \
        unzip \
        vim \
        zip \
    && apt-file update \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    HOMEBREW_NO_ANALYTICS=1 \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH

# Homebrew refuses to run as root. Its standard Linux prefix also allows it to
# use prebuilt bottles on both amd64 and arm64.
RUN useradd --create-home --shell /bin/bash linuxbrew \
    && mkdir -p /home/linuxbrew/.linuxbrew \
    && chmod 0755 /home/linuxbrew \
    && chown -R linuxbrew:linuxbrew /home/linuxbrew

USER linuxbrew

RUN NONINTERACTIVE=1 CI=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    && brew update \
    && brew install \
        bat \
        gcc \
        go \
        ipython \
        jq \
        jupyterlab \
        node \
        ripgrep \
        tmux \
        tree \
        typescript \
        wget \
        wgcf \
    && brew cleanup --prune=all \
    && rm -rf "$(brew --cache)"

USER root

# Preserve conventional, unversioned command names. Homebrew exposes Python as
# python3/pip3 and deliberately suffixes GCC and G++ with their major version.
RUN gcc_path=$(find /home/linuxbrew/.linuxbrew/bin -maxdepth 1 -name 'gcc-[0-9]*' | sort -V | tail -n 1) \
    && gxx_path=$(find /home/linuxbrew/.linuxbrew/bin -maxdepth 1 -name 'g++-[0-9]*' | sort -V | tail -n 1) \
    && test -n "$gcc_path" \
    && test -n "$gxx_path" \
    && ln -s /home/linuxbrew/.linuxbrew/bin/python3 /usr/local/bin/python \
    && ln -s /home/linuxbrew/.linuxbrew/bin/pip3 /usr/local/bin/pip \
    && ln -s "$gcc_path" /usr/local/bin/gcc \
    && ln -s "$gxx_path" /usr/local/bin/g++

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

WORKDIR /app

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bash"]
