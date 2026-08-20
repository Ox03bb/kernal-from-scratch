SRC_DIR := src
INCLUDE_DIR := includes
BUILD_DIR := build
BIN_DIR := bin

# Find all assembly source files in kernal and all C source files in src
KERNEL_ASM_SRCS := $(shell find $(SRC_DIR)/kernal -name '*.asm' -o -name '*.s')
KERNEL_C_SRCS := $(shell find $(SRC_DIR) -name '*.c')

# Bootloader
BOOT_ASM := $(SRC_DIR)/bootloader/boot.asm
BOOT_BIN := $(BIN_DIR)/boot.bin

# Output file
OS_BIN := $(BIN_DIR)/os.bin

# Linker script
LINKER_SCRIPT := linker.ld

# Tools (as they appear in the Docker image)
ASM := nasm
CC := i686-elf-gcc
LD := i686-elf-ld
CLANG_FORMAT := clang-format
CLANG_TIDY := clang-tidy

# Docker settings
DOCKER_IMAGE := cc
DOCKER_RUN := docker run --rm \
	--user $(shell id -u):$(shell id -g) \
	-v $(CURDIR):/work \
	-w /work \
	-e PATH=/home/linuxbrew/.linuxbrew/bin:$$PATH \
	$(DOCKER_IMAGE)

# Compiler flags
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

.PHONY: all clean run debug format format-check lint

all: $(OS_BIN)

#====================================================
# Build kernel inside Docker
#====================================================

$(OS_BIN): $(BOOT_ASM) $(KERNEL_ASM_SRCS) $(KERNEL_C_SRCS) $(LINKER_SCRIPT)
	@echo "Building kernel in Docker..."
	@mkdir -p $(BIN_DIR)
	$(DOCKER_RUN) /bin/bash -c '\
		mkdir -p build/kernal bin && \
		nasm -f bin src/bootloader/boot.asm -o bin/boot.bin && \
		$(foreach src,$(KERNEL_ASM_SRCS),mkdir -p $(dir build/$(subst src/,,$(src:.asm=.asm.o))) && nasm -f elf32 -g $(src) -o build/$(subst src/,,$(src:.asm=.asm.o)) &&) \
		$(foreach src,$(KERNEL_C_SRCS),mkdir -p $(dir build/$(subst src/,,$(src:.c=.o))) && i686-elf-gcc $(CFLAGS) -c $(src) -o build/$(subst src/,,$(src:.c=.o)) &&) \
		i686-elf-ld -r -o build/kernal-linked.o $$(find build -name "*.o" ! -name "kernal-linked.o") && \
		i686-elf-gcc $(CFLAGS) -T linker.ld -o bin/kernel.bin build/kernal-linked.o && \
		cat bin/boot.bin > bin/os.bin && \
		cat bin/kernel.bin >> bin/os.bin && \
		dd if=/dev/zero bs=512 count=8 >> bin/os.bin status=none && \
		chmod 644 bin/os.bin && \
		echo "Kernel built successfully: bin/os.bin"\
	'

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

format:
	find $(SRC_DIR) $(INCLUDE_DIR) -type f \( -name '*.c' -o -name '*.h' \) -exec $(CLANG_FORMAT) -i {} +

format-check:
	find $(SRC_DIR) $(INCLUDE_DIR) -type f \( -name '*.c' -o -name '*.h' \) -exec $(CLANG_FORMAT) --dry-run --Werror {} +

lint:
	find $(SRC_DIR) -type f -name '*.c' -exec $(CLANG_TIDY) {} -- -I$(INCLUDE_DIR) -std=gnu99 -ffreestanding -target i386-elf \;

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)