#!/usr/bin/env bash

yum update -y && yum upgrade -y
yum -y install wget tar unzip initscripts openssh-server openssh-clients

wget -O /usr/bin/systemctl \
    https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py
chmod a+x /usr/bin/systemctl

useradd ${PACKER_USER}
usermod -aG wheel ${PACKER_USER}
echo "${PACKER_USER}:${PACKER_KEY}" | chpasswd

ssh-keygen -A

amazon-linux-extras install ansible2 -y
