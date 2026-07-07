I agree. If this document is meant to prepare the reader for bootloaders and operating system startup, it should explain **how BIOS actually hands control to GRUB**, not just say "loads the bootloader." Those details are fundamental while still fitting in a 2-page document.

Here's what I would include.

---

# BIOS (Basic Input/Output System)

## Overview

The **Basic Input/Output System (BIOS)** is firmware stored in non-volatile flash memory on the motherboard. It is the first software executed after the computer is powered on. Its primary purpose is to initialize the hardware, verify that essential components are working correctly, and start the operating system by loading a **bootloader**.

A bootloader is a small program responsible for loading the operating system kernel into memory. Common bootloaders include **GRUB (Grand Unified Bootloader)** for Linux and **Windows Boot Manager** for Windows.

Modern computers use **UEFI (Unified Extensible Firmware Interface)** instead of the traditional **Legacy BIOS**, but both have the same overall goal: start the operating system.

---

# BIOS Boot Process

When the power button is pressed, the following sequence occurs:

```text
Power Button
      │
      ▼
CPU Reset
      │
      ▼
BIOS Starts
      │
      ▼
POST (Power-On Self-Test)
      │
      ▼
Initialize Hardware
      │
      ▼
Search Boot Device
      │
      ▼
Load Bootloader
      │
      ▼
Bootloader Loads Kernel
      │
      ▼
Operating System
```

During this process, the BIOS:

* Initializes the CPU, RAM, keyboard, display, and storage devices.
* Performs the **Power-On Self-Test (POST)**.
* Searches for a bootable storage device according to the configured boot order.
* Loads a bootloader into memory.
* Transfers control to the bootloader.

After this point, the BIOS is no longer involved in the boot process.

---

# How Legacy BIOS Finds the Bootloader

Legacy BIOS always begins by reading the **first sector** of the selected boot disk.

This sector is called the **Master Boot Record (MBR)** and is exactly **512 bytes** long.

```text
Disk
┌─────────────────────────────┐
│ Master Boot Record (MBR)    │
│ 512 Bytes                   │
└─────────────────────────────┘
            │
            ▼
First Bootloader Code
```

Since 512 bytes is far too small for a complete bootloader like GRUB, the bootloader is divided into multiple stages.

### GRUB Boot Stages (Legacy BIOS)

```
BIOS
   │
   ▼
GRUB Stage 1
   │
   ▼
GRUB Stage 1.5 (optional)
   │
   ▼
GRUB Stage 2
   │
   ▼
Linux Kernel
```

**Stage 1**

* Stored inside the MBR.
* Only a few hundred bytes.
* Its only job is to load the next stage.

**Stage 1.5 (optional)**

* Stored immediately after the MBR (the "MBR gap").
* Contains filesystem drivers (such as ext4 support).
* Used to locate Stage 2.

**Stage 2**

* Stored as normal files in the `/boot/grub/` directory.
* Displays the GRUB menu.
* Loads the selected operating system kernel.

---

# How UEFI Finds the Bootloader

UEFI does **not** read the Master Boot Record to find a bootloader.

Instead, it searches for an **EFI System Partition (ESP)**, a small FAT32 partition that contains bootloader executables.

Example:

```
Disk
├── EFI System Partition (FAT32)
│
├── EFI
│   ├── Microsoft
│   │      └── bootmgfw.efi
│   │
│   └── ubuntu
│          └── grubx64.efi
│
└── Other Partitions
```

Instead of loading boot code from the MBR, UEFI directly executes an **EFI application** such as:

```
grubx64.efi
```

The process becomes:

```
UEFI
   │
   ▼
EFI System Partition
   │
   ▼
grubx64.efi
   │
   ▼
GRUB Menu
   │
   ▼
Linux Kernel
```

Because UEFI loads an executable file directly, it no longer requires the multiple boot stages used by Legacy BIOS.

---

# Legacy BIOS vs UEFI

| Feature             | Legacy BIOS        | UEFI                       |
| ------------------- | ------------------ | -------------------------- |
| Startup Mode        | 16-bit Real Mode   | 32-bit or 64-bit           |
| Boot Method         | Reads the MBR      | Loads an `.efi` executable |
| Bootloader Location | MBR + `/boot/grub` | EFI System Partition       |
| Partition Scheme    | MBR                | GPT (recommended)          |
| Secure Boot         | No                 | Yes                        |
| Current Status      | Legacy             | Modern Standard            |

---

# Summary

The BIOS is responsible for preparing the computer to start the operating system. After initializing the hardware and performing POST, it loads a bootloader.

With **Legacy BIOS**, the firmware reads the **Master Boot Record (MBR)** and begins executing **GRUB Stage 1**, which eventually loads **Stage 2** from the disk before starting the operating system kernel.

With **UEFI**, the firmware skips the MBR entirely. It searches the **EFI System Partition (ESP)** for an EFI executable, such as **`grubx64.efi`**, and executes it directly.

Understanding this distinction is essential because it explains why modern systems use GPT and EFI executables, while older systems relied on the MBR and multi-stage bootloaders.
