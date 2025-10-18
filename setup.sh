#!/bin/sh

PACKAGES="gputils procps make python3-venv"

export DEBIAN_FRONTEND=noninteractive

apt update
apt upgrade -y
apt install -y --no-install-recommends $PACKAGES
