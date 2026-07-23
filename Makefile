SRC_DIR := src
INCLUDE_DIR := includes
BUILD_DIR := build
BIN_DIR := bin

BOOT_ASM := $(SRC_DIR)/bootloader/boot.asm
KERNEL_ASM := $(SRC_DIR)/kernal/entry.asm
KERNEL_C := $(SRC_DIR)/kernal/kernal.c
LINKER_SCRIPT := linker.ld

BOOT_BIN := $(BIN_DIR)/boot.bin
KERNEL_ASM_O := $(BUILD_DIR)/kernel.asm.o
KERNEL_O := $(BUILD_DIR)/kernel.o
KERNEL_BIN := $(BIN_DIR)/kernel.bin
OS_BIN := $(BIN_DIR)/os.bin
COMPLETE_KERNEL := $(BUILD_DIR)/completeKernel.o

ASM := nasm
CC := i686-elf-gcc
LD := i686-elf-ld

DOCKER_IMAGE := cc
DOCKER_RUN := docker run --rm \
	--user $(shell id -u):$(shell id -g) \
	-v $(CURDIR):/work \
	-w /work \
	$(DOCKER_IMAGE)

CFLAGS := \
	-g \
	-O0 \
	-Wall \
	-std=gnu99 \
	-ffreestanding \
	-nostdlib \
	-nostartfiles \
	-nodefaultlibs \
	-I$(INCLUDE_DIR)

.PHONY: all clean run debug os-image-host

all: $(OS_BIN)

#====================================================
# Build inside Docker
#====================================================

$(OS_BIN): $(BOOT_ASM) $(KERNEL_ASM) $(KERNEL_C) $(LINKER_SCRIPT)
	$(DOCKER_RUN) make -f /work/Makefile os-image-host

#====================================================
# Executed inside Docker
#====================================================

os-image-host: $(BOOT_BIN) $(KERNEL_BIN)
	@cat $(BOOT_BIN) > $(OS_BIN)
	@cat $(KERNEL_BIN) >> $(OS_BIN)
	@dd if=/dev/zero bs=512 count=8 >> $(OS_BIN) status=none
	@chmod 644 $(OS_BIN)

#====================================================
# Bootloader
#====================================================

$(BOOT_BIN): $(BOOT_ASM) | $(BIN_DIR)
	$(ASM) -f bin $< -o $@

#====================================================
# Kernel
#====================================================

$(KERNEL_ASM_O): $(KERNEL_ASM) | $(BUILD_DIR)
	$(ASM) -f elf32 -g $< -o $@

$(KERNEL_O): $(KERNEL_C) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(COMPLETE_KERNEL): $(KERNEL_ASM_O) $(KERNEL_O) | $(BUILD_DIR)
	$(LD) -r $^ -o $@

$(KERNEL_BIN): $(COMPLETE_KERNEL) $(LINKER_SCRIPT) | $(BIN_DIR)
	$(CC) $(CFLAGS) \
		-T $(LINKER_SCRIPT) \
		-o $@ \
		$(COMPLETE_KERNEL)

#====================================================
# Directories
#====================================================

$(BUILD_DIR):
	mkdir -p $@

$(BIN_DIR):
	mkdir -p $@

#====================================================
# Run
#====================================================

run: $(OS_BIN)
	qemu-system-i386 \
		-drive file=$(OS_BIN),format=raw \
		-m 512M \
		-serial stdio

#====================================================
# Debug
#====================================================

debug: $(OS_BIN)
	qemu-system-i386 \
		-drive file=$(OS_BIN),format=raw \
		-m 512M \
		-serial stdio \
		-S -s

#====================================================
# Clean
#====================================================

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)