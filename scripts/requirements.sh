if [ -f /etc/arch-release ]; then
    sudo pacman -S --noconfirm --needed nasm qemu-full make git
    yay --noconfirm -S i686-elf-binutils i686-elf-gcc

elif [ -f /etc/debian_version ]; then
    sudo apt-get install -y \
        nasm \
        qemu-system-x86 \
        make \
        git \
        build-essential \
        bison \
        flex \
        libgmp3-dev \
        libmpc-dev \
        libmpfr-dev \
        texinfo \
        xz-utils

elif [ -f /etc/fedora-release ]; then
    sudo dnf install -y \
        nasm \
        qemu-system-x86 \
        make \
        git \
        gcc \
        gcc-c++ \
        binutils \
        bison \
        flex \
        gmp-devel \
        libmpc-devel \
        mpfr-devel \
        texinfo \
        xz

else
    echo "Unsupported distribution."
    exit 1
fi