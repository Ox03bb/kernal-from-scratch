# Real Mode vs Protected Mode

## Overview

When an x86 computer powers on, the processor starts executing in **Real Mode**, a compatibility mode originally designed for the Intel 8086 processor. While Real Mode is sufficient for bootstrapping the system and interacting with the BIOS, it lacks many of the features required by a modern operating system.

For this reason, the bootloader of **SectArch** switches the processor to **Protected Mode** before transferring control to the kernel.

---

# Boot Process

The following diagram illustrates the boot sequence used by SectArch.

```text
Power On
    │
    ▼
 BIOS
    │
    ▼
 Bootloader (Real Mode)
    │
    ├── Load kernel into memory
    ├── Build the Global Descriptor Table (GDT)
    ├── Enable Protected Mode
    │
    ▼
 Kernel (Protected Mode)
```

The BIOS always starts the CPU in Real Mode. The bootloader prepares the hardware and CPU environment before entering Protected Mode and starting the kernel.

---

# Real Mode

## What is Real Mode?

Real Mode is the processor's default operating mode after reset. It provides compatibility with software written for the Intel 8086.

Memory is addressed using the following formula:

```text
Physical Address = Segment × 16 + Offset
```

For example:

```text
CS = 0x1234
IP = 0x5678

Physical Address
= 0x1234 × 16 + 0x5678
= 0x179B8
```

---

## Characteristics

* 16-bit execution
* Uses segmented memory addressing
* Maximum addressable memory is 1 MB
* No memory protection
* No privilege levels
* BIOS interrupts are available
* No virtual memory
* No paging
* No process isolation

---

## Advantages

* Extremely simple
* Fully compatible with BIOS services
* Ideal for bootloaders
* Requires very little initialization

---

## Limitations

Real Mode was never designed to run modern operating systems.

Some of its major limitations include:

### 1. Memory Limit

Only 1 MB of physical memory can be directly addressed.

```text
000000h
...
FFFFFh
```

Modern kernels require significantly more memory for:

* Drivers
* Page tables
* Kernel heap
* File systems
* User processes
* Caches

---

### 2. No Memory Protection

Any instruction can modify any memory location.

For example:

```asm
mov word [0], 0
```

This instruction overwrites the interrupt vector table without any warning.

A single programming error can corrupt the entire operating system.

---

### 3. No User/Kernel Separation

All software executes with the same privileges.

Applications have unrestricted access to:

* Hardware
* Kernel memory
* Interrupt control
* CPU configuration registers

This makes secure multitasking impossible.

---

### 4. No Virtual Memory

Programs must use physical memory addresses directly.

As memory usage grows, allocation becomes increasingly difficult.

---

# Protected Mode

## What is Protected Mode?

Protected Mode is an advanced operating mode introduced with the Intel 80386 processor.

It provides the features necessary for building secure, reliable, and multitasking operating systems.

Once enabled, the CPU begins interpreting segment registers as selectors into the Global Descriptor Table (GDT) instead of traditional Real Mode segments.

---

# Characteristics

* 32-bit execution
* Up to 4 GB address space
* Memory protection
* Privilege levels (Ring 0–3)
* Descriptor-based segmentation
* Interrupt Descriptor Table (IDT)
* Exception handling
* Paging support
* Virtual memory support
* Hardware-enforced protection

---

# Why SectArch Uses Protected Mode

## 1. 32-bit Execution

The kernel can use the full set of 32-bit registers.

```asm
mov eax, 1
mov ebx, 2
add eax, ebx
```

This greatly improves performance and simplifies programming compared to 16-bit code.

---

## 2. Access to More Memory

Protected Mode provides a 32-bit address space.

```text
00000000
...
FFFFFFFF
```

This allows the kernel to manage up to 4 GB of physical memory (without PAE).

SectArch requires this additional memory for:

* Dynamic memory allocation
* Page tables
* Device drivers
* Process memory
* File system caches

---

## 3. Memory Protection

Each segment includes:

* Base address
* Limit
* Access permissions

If software accesses memory outside its permitted region, the CPU immediately raises a **General Protection Fault** instead of allowing memory corruption.

This dramatically improves system stability.

---

## 4. Privilege Levels

Protected Mode introduces four privilege rings.

```text
Ring 0  → Kernel
Ring 1
Ring 2
Ring 3  → User Applications
```

Only Ring 0 is permitted to execute privileged instructions such as:

```asm
cli
lgdt
ltr
mov cr0, eax
```

Applications running in Ring 3 cannot directly control the hardware.

Instead, they request services from the kernel through system calls.

---

## 5. Interrupt Descriptor Table (IDT)

Protected Mode replaces the Real Mode Interrupt Vector Table with the Interrupt Descriptor Table.

The IDT allows the kernel to define dedicated handlers for:

* Hardware interrupts
* CPU exceptions
* Software interrupts

Examples include:

* Divide by zero
* Invalid opcode
* Page fault
* Keyboard interrupt
* Timer interrupt

---

## 6. CPU Exceptions

The processor automatically detects many programming errors.

Examples include:

* Divide-by-zero
* Invalid instruction
* General protection fault
* Page fault

The kernel installs handlers for these exceptions using the IDT.

Without these handlers, the processor cannot safely recover from faults.

---

## 7. Paging

Protected Mode supports paging, which translates virtual addresses into physical addresses.

```text
Virtual Address
        │
        ▼
 Page Tables
        │
        ▼
Physical Address
```

Paging enables:

* Virtual memory
* Process isolation
* Shared memory
* Demand paging

Although paging is supported by Protected Mode, it must be explicitly enabled by the kernel.

---

## 8. Better Security

The CPU automatically verifies:

* Memory permissions
* Segment limits
* Privilege levels
* Descriptor validity

These checks occur entirely in hardware and help prevent accidental or malicious corruption of the operating system.

---

# Why the Bootloader Enables Protected Mode

The BIOS can only start programs in Real Mode.

However, the kernel is designed to execute in Protected Mode.

Therefore, the bootloader performs the transition before transferring control to the kernel.

The sequence is:

1. Load the kernel into memory.
2. Create the Global Descriptor Table (GDT).
3. Load the GDT using `LGDT`.
4. Set the PE (Protection Enable) bit in `CR0`.
5. Perform a far jump into a 32-bit code segment.
6. Initialize segment registers.
7. Jump to the kernel entry point.

This allows the kernel to begin execution in a fully prepared 32-bit environment.

---

# Real Mode vs Protected Mode

| Feature               | Real Mode | Protected Mode          |
| --------------------- | --------- | ----------------------- |
| CPU Width             | 16-bit    | 32-bit                  |
| Maximum Address Space | 1 MB      | 4 GB                    |
| Memory Protection     | No        | Yes                     |
| Privilege Levels      | No        | Ring 0–3                |
| Virtual Memory        | No        | Supported (with paging) |
| Paging                | No        | Supported               |
| Descriptor Tables     | No        | GDT and IDT             |
| CPU Exceptions        | Minimal   | Comprehensive           |
| Process Isolation     | No        | Yes                     |
| BIOS Interrupts       | Available | Not directly available  |

---

# Why SectArch Needs Protected Mode

SectArch cannot provide a modern operating system while remaining in Real Mode.

Protected Mode is required to:

* Execute efficient 32-bit code.
* Access more than 1 MB of memory.
* Protect kernel memory from user applications.
* Handle CPU exceptions safely.
* Support hardware interrupts through the IDT.
* Prepare for virtual memory using paging.
* Implement secure user-mode applications.
* Build a stable multitasking operating system.

For these reasons, the bootloader switches the processor into Protected Mode before transferring execution to the SectArch kernel.

---

# Future Transition to Long Mode

Protected Mode is not the final execution mode for 64-bit systems.

A 64-bit kernel follows this sequence:

```text
Real Mode
      │
      ▼
Protected Mode
      │
Enable Paging
      │
Enable Long Mode
      │
      ▼
64-bit Kernel
```

Long Mode cannot be entered directly from Real Mode. The processor must first transition through Protected Mode.

---

# Summary

Real Mode exists primarily for backward compatibility and system initialization. It provides only the functionality required to start the computer and interact with the BIOS.

Protected Mode introduces the memory management, security, interrupt handling, and privilege mechanisms required by a modern operating system. By entering Protected Mode before executing the kernel, SectArch gains access to these capabilities and establishes the foundation for future features such as paging, user-mode processes, multitasking, and eventually 64-bit Long Mode.
