FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    build-essential \
    bison \
    flex \
    texinfo \
    libgmp3-dev \
    libmpc-dev \
    libmpfr-dev \
    wget \
    curl \
    git \
    file \
    ca-certificates \
    xz-utils \
    make \
    nasm \
 && rm -rf /var/lib/apt/lists/*

RUN NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

RUN brew install i686-elf-gcc

RUN i686-elf-gcc --version