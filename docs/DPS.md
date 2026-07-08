# Disk Partitioning Schemes (DPS)

## Index

- [Disk Partitioning Schemes (DPS)](#disk-partitioning-schemes-dps)
  - [Index](#index)
- [What is MBR?](#what-is-mbr)
  - [Boot process with MBR](#boot-process-with-mbr)
  - [MBR limitations](#mbr-limitations)
    - [1. Maximum disk size](#1-maximum-disk-size)
    - [2. Only 4 primary partitions](#2-only-4-primary-partitions)
    - [3. Single point of failure](#3-single-point-of-failure)
- [What is GPT?](#what-is-gpt)
  - [GPT layout](#gpt-layout)
  - [GPT Header](#gpt-header)
  - [GPT Partition Entries](#gpt-partition-entries)
- [Why does GPT still contain an MBR?](#why-does-gpt-still-contain-an-mbr)
- [Boot process with GPT](#boot-process-with-gpt)
- [MBR vs GPT](#mbr-vs-gpt)
- [What is a GUID?](#what-is-a-guid)
- [Can BIOS use GPT?](#can-bios-use-gpt)
- [Are there other partitioning systems?](#are-there-other-partitioning-systems)
- [Which should you use today?](#which-should-you-use-today)


# What is MBR?

**MBR (Master Boot Record)** is the oldest partitioning system, introduced with the IBM PC in **1983**.

It occupies the **first sector of the disk (LBA 0)**, which is only **512 bytes**.

Its responsibilities are:

1. Store a small bootloader.
2. Store the partition table.
3. Store a boot signature.

```
Sector 0 (512 bytes)

+-------------------------+
| Bootloader (446 bytes)  |
+-------------------------+
| Partition Table (64 B)  |
+-------------------------+
| Signature 55 AA (2 B)   |
+-------------------------+
```

The partition table contains **4 entries**, each describing one partition.

---

## Boot process with MBR

```
Power On
    │
    ▼
BIOS
    │
    ▼
Reads Sector 0
    │
    ▼
Executes MBR Bootloader
    │
    ▼
Bootloader loads Stage 2
    │
    ▼
GRUB / Windows Boot Manager
    │
    ▼
Kernel
```

---

## MBR limitations

### 1. Maximum disk size

MBR uses **32-bit addresses**.

```
2^32 sectors
```

With 512-byte sectors:

```
2^32 × 512
≈ 2 TB
```

So MBR cannot fully use disks larger than **2 TB**.

---

### 2. Only 4 primary partitions

The partition table has space for only four entries.

```
Primary
Primary
Primary
Primary
```

To create more partitions, one must be an **Extended Partition**, which contains multiple logical partitions.

Example:

```
Primary
Primary
Primary
Extended
    ├── Logical
    ├── Logical
    └── Logical
```

---

### 3. Single point of failure

Everything important is stored in one sector.

If sector 0 becomes corrupted:

* partition information may be lost
* bootloader may be lost

---

# What is GPT?

**GPT (GUID Partition Table)** is the modern partitioning scheme introduced as part of the Unified Extensible Firmware Interface (UEFI) specification.

It replaces MBR.

GPT is designed for:

* very large disks
* many partitions
* better reliability
* redundancy

---

## GPT layout

```
+-------------------------+
| Protective MBR          |
+-------------------------+
| GPT Header              |
+-------------------------+
| Partition Entries       |
+-------------------------+

...

Data Partitions

...

+-------------------------+
| Backup Partition Table  |
+-------------------------+
| Backup GPT Header       |
+-------------------------+
```

Unlike MBR, GPT stores a **backup copy** at the end of the disk.

---

## GPT Header

Contains information such as:

* disk GUID
* location of partition table
* number of partitions
* CRC checksum
* backup header location

---

## GPT Partition Entries

Each partition has information including:

* unique GUID
* partition type
* first sector
* last sector
* partition name

A partition entry is **128 bytes**.

Most operating systems reserve space for **128 partitions** by default.

---

# Why does GPT still contain an MBR?

GPT begins with something called a **Protective MBR**.

Its purpose is **not booting**.

Instead, it prevents old MBR-only software from mistakenly thinking the disk is empty and overwriting it.

```
Disk

Sector 0
┌─────────────────────┐
│ Protective MBR      │
└─────────────────────┘

Sector 1
┌─────────────────────┐
│ GPT Header          │
└─────────────────────┘
```

---

# Boot process with GPT

```
Power On
      │
      ▼
UEFI Firmware
      │
      ▼
Reads GPT
      │
      ▼
Find EFI System Partition (ESP)
      │
      ▼
Loads EFI Bootloader
      │
      ▼
   GRUB EFI
      or
Windows Boot Manager
      │
      ▼
Kernel
```

Unlike BIOS, UEFI loads an **EFI executable** (such as `grubx64.efi` or `bootmgfw.efi`) directly from the **EFI System Partition (ESP)**.

---

# MBR vs GPT

| Feature                | MBR   | GPT                                             |
| ---------------------- | ----- | ----------------------------------------------- |
| Introduced             | 1983  | 1990s (UEFI era)                                |
| Firmware               | BIOS  | UEFI (can also be used with BIOS in some cases) |
| Max disk size          | 2 TB  | ~9.4 ZB (with 64-bit LBAs)                      |
| Primary partitions     | 4     | Typically 128 by default                        |
| Backup partition table | No    | Yes                                             |
| CRC integrity checking | No    | Yes                                             |
| Unique partition IDs   | No    | Yes (GUIDs)                                     |
| Reliability            | Lower | Higher                                          |

---

# What is a GUID?

A **GUID (Globally Unique Identifier)** is a 128-bit identifier that is intended to be unique worldwide.

Example:

```
28732AC1-1FF8-4B8C-93A9-2D2D2DDE5B13
```

Every GPT disk has a GUID.

Every GPT partition also has its own GUID.

---

# Can BIOS use GPT?

Yes, but with limitations.

* **BIOS + MBR** → traditional combination.
* **UEFI + GPT** → modern standard.
* **BIOS + GPT** → possible if the bootloader (for example, GRUB) uses a small BIOS Boot Partition.
* **UEFI + MBR** → also possible on many systems, though GPT is generally preferred.

---

# Are there other partitioning systems?

Yes. Besides MBR and GPT, several others have been used on specific platforms:

| Partition Scheme             | Used By                        | Status                              |
| ---------------------------- | ------------------------------ | ----------------------------------- |
| Apple Partition Map (APM)    | Classic Macintosh (PowerPC)    | Legacy                              |
| BSD Disklabel                | BSD operating systems          | Still used inside BSD installations |
| Sun Disk Label               | Sun SPARC systems              | Legacy                              |
| SGI Disk Label               | SGI workstations               | Legacy                              |
| Amiga Rigid Disk Block (RDB) | Amiga computers                | Legacy                              |
| GPT                          | Modern PCs and servers         | Current standard                    |
| MBR                          | Older PCs and embedded systems | Legacy but still supported          |

---

# Which should you use today?

For almost all modern systems:

* Use **GPT** for new installations.
* Use **UEFI** firmware when available.
* Use an **EFI System Partition (ESP)** formatted as FAT32.

Only use **MBR** if you need compatibility with very old BIOS-based hardware or legacy operating systems.

**Rule of thumb:**

```
Old PC (BIOS)
      ↓
     MBR

Modern PC (UEFI)
      ↓
     GPT
```

For current Windows and Linux installations on modern hardware, **UEFI + GPT** is the recommended configuration.
