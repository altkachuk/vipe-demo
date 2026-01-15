#!/usr/bin/env bash
set -e

apt update
apt install -y \
	git \
    cmake \
    ninja-build \
    build-essential \
    cuda-nvcc-12-8 \
    libgl1 \
    libglib2.0-0 \
    wget \
    ffmpeg

# Conda installation
cd ~
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh