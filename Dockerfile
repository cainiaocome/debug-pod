FROM python:3

RUN apt update && 
    apt install apt-file -y &&
    apt-file update
