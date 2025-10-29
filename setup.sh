#!/bin/sh

PACKAGES="gputils procps make python3-venv jq git"

export DEBIAN_FRONTEND=noninteractive

apt update
apt upgrade -y
apt install -y --no-install-recommends $PACKAGES

python3 -m venv /root/venv

PICPRO=git+https://github.com/Salamek/picpro.git@master
#PICPRO=picpro

/root/venv/bin/pip install "${PICPRO}"

ln -f -s /root/venv/bin/picpro /usr/local/bin/
