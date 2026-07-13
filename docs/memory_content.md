# Overview of memory after the BIOS

A simplified memory map looks like this:

```text
Physical Memory

0x000000  +---------------------------+
          | Interrupt Vector Table    | 1 KB
0x000400  +---------------------------+
          | BIOS Data Area (BDA)      | 256 B
0x000500  +---------------------------+
          | Free RAM                  |
          |                           |
          | (your stack can go here)  |
          |                           |
0x007C00  +---------------------------+
          | Bootloader (512 bytes)    |
0x007E00  +---------------------------+
          | Free RAM                  |
          |                           |
          |                           |
0x09FC00  +---------------------------+
          | Extended BIOS Data Area   |
0x0A0000  +---------------------------+
          | VGA Video Memory          |
0x0C0000  +---------------------------+
          | Video BIOS ROM            |
0x0F0000  +---------------------------+
          | System BIOS ROM           |
0x100000  +---------------------------+
```

---

# 1. Interrupt Vector Table (IVT)

Address:

```text
0x00000
```

Size:

```text
1024 bytes
```

Contains:

```text
256 interrupt handlers

INT 0x00
INT 0x01
...
INT 0xFF
```

Each entry contains a segment:offset pointer to the BIOS interrupt handler.

For example:

```asm
int 0x10
```

The CPU looks up vector `0x10` in the IVT and jumps to the BIOS video service.

---

# 2. BIOS Data Area (BDA)

Starts at

```text
0x400
```

Contains information such as:

* Keyboard status
* COM ports
* LPT ports
* Number of disk drives
* Timer tick count
* Video mode
* Screen dimensions

Many BIOS interrupts read information from the BDA.

---

# 3. Your bootloader

The BIOS reads the first sector (512 bytes) from the boot device into:

```text
0x7C00
```

So if your source contains:

```asm
org 0x7C00
```

your code is located at:

```text
0x7C00
```

and spans:

```text
0x7C00
to
0x7DFF
```

---

# 4. Stack

The BIOS does **not** guarantee a usable stack.

Different BIOS implementations initialize `SS:SP` differently, so you should **always initialize your own stack** before making assumptions.

A common setup is:

```asm
mov ax, 0
mov ss, ax
mov sp, 0x7C00
```

or place it elsewhere in free RAM, depending on your bootloader design.

---

# 5. Free RAM

Everything between roughly

```text
0x500
```

and

```text
0x9FC00
```

is generally available for your bootloader and kernel loading, although you should eventually obtain the actual memory map using BIOS interrupt `INT 15h, E820h`.

Typical uses include:

* Loading additional sectors
* Temporary buffers
* Stack
* Second-stage bootloader

---

# 6. Video memory

Starts at

```text
0xA0000
```

or

```text
0xB8000
```

depending on the video mode.

For text mode:

```text
0xB8000
```

contains the characters displayed on the screen.

Each character occupies two bytes:

```text
Character
Attribute
```

Example:

```text
0xB8000

'H'
0x07
```

---

# 7. BIOS ROM

Near the top of the first megabyte:

```text
0xF0000
```

The BIOS code itself resides in ROM (or firmware mapped into memory).

When you execute:

```asm
int 0x10
```

the CPU eventually runs code from this BIOS ROM.

---

# 8. CPU Registers

The BIOS also leaves the CPU with initialized registers, but **their values are not fully standardized**.

The only reliable value is typically:

```text
DL
```

which contains the BIOS boot drive number:

* `0x00` = Floppy
* `0x80` = First hard disk
* `0x81` = Second hard disk

You should preserve `DL` if you intend to load more sectors from the boot device.

---

# 9. Segment Registers

Most BIOSes start execution with `CS:IP` pointing to your bootloader, but the exact segment values can vary.

For example, some BIOSes use:

```text
CS = 0x0000
IP = 0x7C00
```

Others may use:

```text
CS = 0x07C0
IP = 0x0000
```

Both refer to the same physical address (`0x7C00`).

For portability, many bootloaders immediately normalize the segment registers:

```asm
cli

xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7C00

sti
```

---

# Summary

Immediately after the BIOS transfers control to your minimal bootloader, memory already contains:

| Memory Region       | Contents                                          |
| ------------------- | ------------------------------------------------- |
| `0x00000–0x003FF`   | Interrupt Vector Table (256 interrupt vectors)    |
| `0x00400–0x004FF`   | BIOS Data Area                                    |
| `0x00500–0x07BFF`   | Free conventional RAM                             |
| `0x07C00–0x07DFF`   | Your 512-byte bootloader                          |
| `0x07E00–0x09FBFF`  | More free conventional RAM                        |
| `0x09FC00–0x09FFFF` | Extended BIOS Data Area (EBDA, location may vary) |
| `0x0A0000–0x0BFFFF` | Video memory                                      |
| `0x0C0000–0x0FFFFF` | BIOS and option ROMs                              |

As you continue your kernel project, you'll gradually replace BIOS services with your own implementations: first setting up a stack, then enabling Protected Mode, then paging, and eventually no longer relying on BIOS interrupts at all.
