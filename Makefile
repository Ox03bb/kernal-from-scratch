SRC_DIR := src
BUILD_DIR := build

BIN_DIR := bin

FLAGS :=

BOOT_DIR := $(SRC_DIR)/bootloader

BOOT_SRC := $(BOOT_DIR)/boot.asm

BOOT_BIN := $(BUILD_DIR)/boot.bin
DISK_IMG := $(BUILD_DIR)/disk.img

all: $(BOOT_BIN) $(DISK_IMG)

# Build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Ensure bin directory exists as well
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

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

# Kernel build
KERNEL_DIR := $(SRC_DIR)/kernal
KERNEL_ASM := $(KERNEL_DIR)/entry.asm
KERNEL_C := $(KERNEL_DIR)/kernal.c

$(BUILD_DIR)/kernel.asm.o: $(KERNEL_ASM) | $(BUILD_DIR)
	nasm -f elf -g $< -o $@

$(BUILD_DIR)/kernel.o: $(KERNEL_C) | $(BUILD_DIR)
	i686-elf-gcc -I$(SRC_DIR) $(FLAGS) -std=gnu99 -c $< -o $@

$(BUILD_DIR)/completeKernel.o: $(BUILD_DIR)/kernel.asm.o $(BUILD_DIR)/kernel.o
	i686-elf-ld -g -relocatable $^ -o $@

$(BIN_DIR)/kernel.bin: $(BUILD_DIR)/completeKernel.o | $(BIN_DIR)
	i686-elf-gcc $(FLAGS) -T ./linker.ld -o $@ -ffreestanding -O0 -nostdlib $(BUILD_DIR)/completeKernel.o

.PHONY: kernel
kernel: $(BIN_DIR)/kernel.bin