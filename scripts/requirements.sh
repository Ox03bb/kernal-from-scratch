# if os is arch based

if [ -f /etc/arch-release ]; then
    sudo pacman -S --noconfirm --needed nasm qemu-full make git
else if [ -f /etc/debian_version ]; then
    sudo apt-get install -y nasm qemu make git
fi
    