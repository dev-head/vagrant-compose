#!/usr/bin/env bash

##
# Tools
##
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends --no-install-suggests \
    apt-transport-https \
    software-properties-common \
    make \
    iputils-ping \
    sudo \
    vim \
    unzip \
    htop \
    iftop \
    iotop \
    ntp \
    nmap \
    dirmngr \
    git \
    net-tools \
    wget \
    curl \
    python \
    ruby \
    lsof \
    mlocate \
    ca-certificates \
    cron \
    autofs \
    nfs-common \
    aufs-tools \
    jq \
    apparmor \
    rsyslog \
    python-setuptools \
    python-pip \
    supervisor \
    sysstat

# Install a www user for nginx.
# This allows us to fake it and work locally with our code mounted in the container.
# The uid is pulled from the user created in the container, this isn't going to be very portable.
useradd --user-group --shell=/dev/null --uid=80 www

IMAGES=$(docker ps -aq)
if [[ ${IMAGES} ]]; then

    echo "[DOCKER]::[stop all]::[containers]"
    test=$(docker stop ${IMAGES} >> /dev/null 2>&1)

    echo "[DOCKER]::[remove all]::[containers]"
    test=$(docker rm -v ${IMAGES}  >> /dev/null 2>&1)

    echo "[DOCKER]::[delete all]::[images]"
    test=$(docker rmi ${IMAGES} >> /dev/null 2>&1)
fi

echo "I have exorcised the demons!"