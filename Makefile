SRC_DIR := src
BUILD_DIR := build

BOOT_DIR := $(SRC_DIR)/bootloader
KERNEL_DIR := $(SRC_DIR)/kernel

BOOT_SRC := $(BOOT_DIR)/boot.asm

BOOT_BIN := $(BUILD_DIR)/boot.bin
BOOT_ELF := $(BUILD_DIR)/boot.elf
DISK_IMG := $(BUILD_DIR)/disk.img

all: $(BOOT_BIN) $(BOOT_ELF) $(DISK_IMG)

# Build directory

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Boot sector (flat binary)

$(BOOT_BIN): $(BOOT_SRC) | $(BUILD_DIR)
	nasm -f bin $< -o $@

# ELF with debug symbols (for GDB only)

$(BOOT_ELF): $(BOOT_SRC) | $(BUILD_DIR)
	nasm -f elf64 -g -F dwarf $< -o $(BUILD_DIR)/boot.o
	ld -o $@ $(BUILD_DIR)/boot.o

# Disk image

$(DISK_IMG): $(BOOT_BIN)
	dd if=/dev/zero of=$@ bs=512 count=2880
	dd if=$(BOOT_BIN) of=$@ conv=notrunc

# Run

run: $(DISK_IMG)
	qemu-system-x86_64 \
		-drive format=raw,file=$<

# Debug

debug: $(DISK_IMG)
	qemu-system-x86_64 \
		-drive format=raw,file=$< \
		-S \
		-s >build/qemu.log 2>&1 &



gdb: 
	pwndbg -x conf.gdb

# Clean

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run debug clean