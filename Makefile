SRC_DIR := src
BUILD_DIR := build

BOOT_DIR := $(SRC_DIR)/bootloader
KERNEL_DIR := $(SRC_DIR)/kernel


all: $(BUILD_DIR)/boot.bin

$(BUILD_DIR): 
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/boot.bin: $(BOOT_DIR)/main.asm | $(BUILD_DIR)
	nasm -f bin $< -o $(BUILD_DIR)/boot.bin

run: $(BUILD_DIR)/boot.bin
	qemu-system-x86_64 -drive format=raw,file=$<
