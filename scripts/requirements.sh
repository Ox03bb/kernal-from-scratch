if [ -f /etc/arch-release ]; then
    sudo pacman -S --noconfirm --needed nasm qemu-full make git
    yay --noconfirm  -S i686-elf-binutils i686-elf-gcc 
else if [ -f /etc/debian_version ]; then
    sudo apt-get install -y nasm qemu make git\
    build-essential \
    bison \
    flex \
    libgmp3-dev \
    libmpc-dev \
    libmpfr-dev \
    texinfo \
    xz-utils
fi
    