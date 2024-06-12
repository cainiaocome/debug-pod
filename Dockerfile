FROM python:3

RUN apt update && \
    apt install apt-file -y && \
    apt-file update && \
    apt install -y iputils-ping iproute2 git curl wget vim tmux tree htop nfs-common
