#!/usr/bin/env bash
set -e

apt-get update
apt-get install \
    git \
    cmake \
    ninja-build \
    build-essential \
    libboost-program-options-dev \
    libboost-graph-dev \
    libboost-system-dev \
    libeigen3-dev \
    libfreeimage-dev \
    libmetis-dev \
    libgoogle-glog-dev \
    libgtest-dev \
    libgmock-dev \
    libsqlite3-dev \
    libglew-dev \
    qt6-base-dev \
    libqt6opengl6-dev \
    libqt6openglwidgets6 \
    libcgal-dev \
    libceres-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libmkl-full-dev
