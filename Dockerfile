FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

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
    sudo \
 && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash builder \
    && echo "builder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/builder

USER builder
WORKDIR /home/builder

# Install Homebrew
RUN NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

# Install cross compiler
RUN brew install i686-elf-gcc

# Verify
RUN i686-elf-gcc --version

WORKDIR /kernel

CMD ["/bin/bash"]