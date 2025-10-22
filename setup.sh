#!/bin/sh

PACKAGES="gputils procps make python3-venv jq"

export DEBIAN_FRONTEND=noninteractive

apt update
apt upgrade -y
apt install -y --no-install-recommends $PACKAGES

python3 -m venv /root/venv
/root/venv/bin/pip install picpro
ln -s /root/venv/bin/picpro /usr/local/bin/
