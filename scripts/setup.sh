#!/bin/bash

sudo apt update && sudo apt install -y \
    bc bison build-essential ccache curl flex \
    g++-multilib gcc-multilib git gnupg gperf \
    lib32readline-dev lib32z1-dev \
    liblz4-tool libncurses5-dev libsdl1.2-dev \
    libssl-dev libxml2 libxml2-utils \
    zstd pigz lzop \
    rsync schedtool squashfs-tools zip \
    android-tools-adb android-tools-fastboot \
    python3 python3-pip jq \
    repo \
    git-lfs \
    android-sdk-platform-tools-common

sudo apt upgrade -y

echo "Setting Up AOSP Build Environment"
setup
