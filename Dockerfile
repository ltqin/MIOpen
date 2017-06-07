FROM ubuntu:16.04

ARG PREFIX=/opt/rocm
ARG GITLAB1=10.236.13.205

# Support multiarch
RUN dpkg --add-architecture i386

# Add rocm repository
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl && \
    curl -sL http://packages.amd.com/rocm/apt/debian/rocm.gpg.key | apt-key add - && \
    sh -c 'echo deb [arch=amd64] http://packages.amd.com/rocm/apt/debian/ xenial main > /etc/apt/sources.list.d/rocm.list'

# Install dependencies required to build hcc
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    clang-3.8 \
    clang-format-3.8 \
    clang-tidy-3.8 \
    cmake \
    curl \
    g++-mingw-w64 \
    g++-mingw-w64-x86-64 \
    g++-multilib \
    git \
    hsa-rocr-dev \
    hsakmt-roct-dev \
    libelf-dev \
    libncurses5-dev \
    libpthread-stubs0-dev \
    mingw-w64 \
    mingw-w64-tools \
    nsis \
    python \
    python-dev \
    python-pip \
    rocm-opencl-dev \
    software-properties-common \
    wget \
    wine \
    xvfb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install an init system
RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb
RUN dpkg -i dumb-init_*.deb && rm dumb-init_*.deb

# Add the toolchain
ADD cmake/mingw-toolchain.cmake $PREFIX/x86_64-w64-mingw32/cmake/toolchain.cmake

# Setup wine
RUN mkdir -p /jenkins
RUN chmod 777 /jenkins
RUN WINEDEBUG=-all DISPLAY=:55.0 wineboot; wineserver -w

# Install cget
RUN pip install cget

# Add rocm recipes
RUN cget -p $PREFIX install http://$GITLAB1/pfultz/roc-recipes/repository/archive.tar.gz?ref=master -DGITLAB1=$GITLAB1

# Add rocm recipes for windows
RUN cget -p $PREFIX/x86_64-w64-mingw32 init -t $PREFIX/x86_64-w64-mingw32/cmake/toolchain.cmake
RUN cget -p $PREFIX/x86_64-w64-mingw32 install http://$GITLAB1/pfultz/roc-recipes/repository/archive.tar.gz?ref=master -DGITLAB1=$GITLAB1

# Build hcc
RUN cget -p $PREFIX install hcc

# Not needed by miopen, but it helps downstream applications
RUN ln -s $PREFIX $PREFIX/hip
RUN ln -s $PREFIX $PREFIX/hcc

# Build using hcc
RUN cget -p $PREFIX init --cxx $PREFIX/bin/hcc

# Install dependencies
RUN cget -p $PREFIX install boost hip clang-ocl tinygemm RadeonOpenCompute/rocm-cmake@master

# Install windows dependencies
RUN cget -p $PREFIX/x86_64-w64-mingw32 install boost meganz/mingw-std-threads RadeonOpenCompute/rocm-cmake@master

# Install windows opencl
RUN curl http://$GITLAB1/pfultz/mlopen/uploads/bbab72ad68e65faeee9257b2bb9ca4a1/win-opencl.deb > /win-opencl.deb
RUN dpkg -i /win-opencl.deb && rm /win-opencl.deb
