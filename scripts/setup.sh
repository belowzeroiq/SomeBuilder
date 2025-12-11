#!/bin/bash

sudo apt update && sudo apt install -y \
  bc bison build-essential ccache curl \
  flex g++-multilib gcc-multilib git git-lfs \
  gnupg gperf imagemagick lib32ncurses-dev lib32readline-dev \
  lib32z1-dev liblz4-tool libncurses6 libncurses-dev \
  libsdl1.2-dev libssl-dev libwxgtk3.2-dev libxml2 libxml2-utils \
  lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev \
  git repo wget jq \
  python-is-python3 aria2

sudo apt upgrade -y

wget http://security.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.2-0ubuntu2_amd64.deb && sudo dpkg -i libtinfo5_6.2-0ubuntu2_amd64.deb && rm -rf libtinfo5_6.2-0ubuntu2_amd64.deb

wget https://github.com/xordinaryme/builder/releases/download/v1/libncurses5_6.2-0ubuntu2_amd64.deb && sudo dpkg -i libncurses5_6.2-0ubuntu2_amd64.deb && rm -rf libncurses5_6.2-0ubuntu2_amd64.deb

echo "Setting Up AOSP Build Environment"
