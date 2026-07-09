SRC_DIR := src
BUILD_DIR := build

BOOT_DIR := $(SRC_DIR)/bootloader

BOOT_SRC := $(BOOT_DIR)/boot.asm

BOOT_BIN := $(BUILD_DIR)/boot.bin
DISK_IMG := $(BUILD_DIR)/disk.img

all: $(BOOT_BIN) $(DISK_IMG)

# Build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Boot sector
$(BOOT_BIN): $(BOOT_SRC) | $(BUILD_DIR)
	nasm -f bin $< -o $@

# Disk image
$(DISK_IMG): $(BOOT_BIN)
	dd if=/dev/zero of=$@ bs=512 count=2880
	dd if=$(BOOT_BIN) of=$@ conv=notrunc



# Run
run: $(DISK_IMG)
	qemu-system-x86_64 \
		-drive format=raw,file=$<

# Start QEMU waiting for GDB
debug: $(DISK_IMG)
	qemu-system-x86_64 \
		-drive format=raw,file=$< \
		-S \
		-s

# Connect GDB
gdb:
	pwndbg -x conf.gdb

# Clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run debug gdb clean