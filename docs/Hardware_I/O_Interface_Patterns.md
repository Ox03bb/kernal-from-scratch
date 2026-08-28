# Hardware I/O Interface Patterns

When writing an operating-system kernel, the CPU communicates with hardware devices through **hardware interfaces**.

Different devices expose their registers differently. There is no universal rule that says:

> "The first port is always a command port."

The device's hardware specification defines what each port or memory address means.

This document covers the most common hardware I/O patterns encountered when developing a kernel.

---

## 1. Port I/O

On x86, some devices expose registers through the CPU's **I/O port address space**.

The CPU accesses these ports using instructions such as:

```c
outb(port, value);
```

and:

```c
value = inb(port);
```

Conceptually:

```text
CPU
 │
 │ in / out
 ▼
I/O Port
 │
 ▼
Hardware Device
```

A device can expose several ports, each with a different purpose.

For example:

```text
Device
 ├── Command
 ├── Data
 ├── Status
 └── Configuration
```

The exact meaning of each port is device-specific.

---

# 2. Command + Data

The **Command + Data** pattern separates operations from the values used by those operations.

```text
             Device
                │
        ┌───────┴───────┐
        │               │
     Command           Data
        │               │
   "What to do?"    "What value?"
```

The kernel might perform:

```c
outb(COMMAND_PORT, command);
outb(DATA_PORT, data);
```

## Example: PIC

The 8259A PIC exposes:

```text
Master PIC
    0x20 → Command
    0x21 → Data

Slave PIC
    0xA0 → Command
    0xA1 → Data
```

For example:

```c
outb(0x20, 0x11);
```

sends an initialization command to the master PIC.

Then:

```c
outb(0x21, 0x20);
```

sends configuration data through the data port.

### Important

The fact that a device uses a command port does **not** mean every device uses the same layout.

The hardware specification defines the interface.

---

# 3. Index + Data

The **Index + Data** pattern is useful when a device contains many internal registers but exposes only a small number of I/O ports.

The first port selects a register:

```text
Index port
     │
     └── "Which register?"
```

The second port accesses that register:

```text
Data port
     │
     └── "What value?"
```

Conceptually:

```text
             Device
                │
        ┌───────┴───────┐
        │               │
      Index            Data
        │               │
 "Select register"  "Read/write value"
```

## Example: VGA

The VGA CRT Controller uses:

```text
0x3D4 → Index
0x3D5 → Data
```

To access register `0x0E`:

```c
outb(0x3D4, 0x0E);
```

This selects register `0x0E`.

Then:

```c
outb(0x3D5, value);
```

writes the value to that selected register.

The sequence is:

```text
CPU
 │
 │ 0x0E
 ▼
VGA Index Port
 │
 │ select register
 ▼
Register 0x0E
 │
 │
 ▼
VGA Data Port
 │
 │ value
 ▼
Register 0x0E
```

This pattern is common in older hardware.

---

# 4. Status + Data

The **Status + Data** pattern separates the device's state from the actual data being transferred.

```text
             Device
                │
        ┌───────┴───────┐
        │               │
      Status            Data
        │               │
 "What is happening?"  "Actual data"
```

The kernel might do:

```c
while (!(inb(STATUS_PORT) & DEVICE_READY))
    ;

value = inb(DATA_PORT);
```

The status register tells the kernel whether an operation can proceed.

For example:

```text
Status
 ├── Ready
 ├── Busy
 ├── Error
 └── Data available
```

A common sequence is:

```text
CPU
 │
 │ read status
 ▼
Device
 │
 ├── BUSY → wait
 │
 └── READY
       │
       ▼
    read/write data
```

This is often called **polling** because the CPU repeatedly checks the device's status.

---

# 5. Control + Status + Data

More complex devices often expose several different registers.

A common organization is:

```text
Device
 ├── Control
 ├── Status
 ├── Data
 └── Configuration
```

### Control

The control register tells the device what to do.

```c
outb(CONTROL, START);
```

### Status

The status register tells the kernel what is happening.

```c
status = inb(STATUS);
```

### Data

The data register contains the data being transferred.

```c
data = inb(DATA);
```

A typical interaction is:

```text
        CPU
         │
         │ START
         ▼
     Control
         │
         ▼
      Device
         │
         │ BUSY
         ▼
      Status
         │
         │ DONE
         ▼
        CPU
         │
         │ read
         ▼
        Data
```

This is one of the most common conceptual models for hardware devices.

---

# 6. Register-Based Device Interface

Instead of thinking only in terms of ports, it is useful to think of a device as exposing a collection of **registers**.

For example:

```text
Device registers

0x00 → Control
0x04 → Status
0x08 → Data
0x0C → Configuration
0x10 → Interrupt configuration
```

The kernel's driver knows:

```text
Register address
      +
Register meaning
      +
Allowed operations
```

The driver therefore acts as an abstraction layer:

```text
Application
     │
     ▼
Kernel
     │
     ▼
Driver
     │
     ▼
Device Registers
     │
     ▼
Hardware
```

---

# 7. MMIO — Memory-Mapped I/O

Modern hardware often uses **Memory-Mapped I/O (MMIO)**.

Instead of accessing a device through an I/O port:

```c
outb(PORT, value);
```

the device registers are mapped into the CPU's memory address space.

Conceptually:

```text
CPU Address Space
┌─────────────────────────┐
│ RAM                     │
├─────────────────────────┤
│ RAM                     │
├─────────────────────────┤
│ Device MMIO registers   │
│                         │
│ Control                 │
│ Status                  │
│ Data                    │
└─────────────────────────┘
```

The CPU accesses these addresses using normal memory operations.

For example:

```c
volatile uint32_t *reg =
    (volatile uint32_t *)DEVICE_REGISTER;

*reg = value;
```

The `volatile` qualifier is important because hardware registers can change independently of the CPU.

The compiler must not optimize away accesses that are required to communicate with hardware.

---

# 8. Port I/O vs MMIO

There are two major ways x86 hardware can expose registers.

## Port I/O

```text
CPU
 │
 │ inb / outb
 ▼
I/O Port
 ▼
Device
```

Example:

```c
outb(0x20, 0x11);
```

## MMIO

```text
CPU
 │
 │ memory load/store
 ▼
Memory Address
 ▼
Device Register
```

Example:

```c
*(volatile uint32_t *)address = value;
```

Comparison:

| Property       | Port I/O           | MMIO                 |
| -------------- | ------------------ | -------------------- |
| Address space  | I/O address space  | Memory address space |
| Typical access | `in` / `out`       | Load / store         |
| Example        | PIC                | PCI devices          |
| Common in      | Older x86 hardware | Modern hardware      |

---

# 9. FIFO / Queue

Some devices expose a stream of data through a **FIFO (First In, First Out)** buffer.

Conceptually:

```text
        Device
           │
           ▼
     ┌─────────────┐
     │ FIFO        │
     │             │
     │ A B C D E   │
     └─────────────┘
           │
           ▼
          CPU
```

The first value written is the first value read.

```text
Write:
A → B → C → D

Read:
A → B → C → D
```

The kernel may repeatedly access a data register:

```c
while (data_available()) {
    value = read_data();
}
```

FIFOs are useful for:

* Serial communication
* Network devices
* Keyboard input
* Audio
* Device buffers

---

# 10. Polling

Polling is not exactly a register layout, but it is a very common way to interact with hardware.

The kernel repeatedly checks a status register:

```c
while (!(read_status() & READY))
    ;
```

Conceptually:

```text
       ┌─────────────┐
       │ Read Status │
       └──────┬──────┘
              │
          Ready?
         /      \
       No        Yes
       │          │
       ▼          ▼
     Wait      Use device
       │
       └───────────────┐
                       │
                       ▼
                 Read Status
```

Polling is simple but can waste CPU time.

For this reason, kernels often use **interrupts** instead.

---

# 11. Interrupt-Driven I/O

Instead of constantly checking:

```text
"Are you ready?"
"Are you ready?"
"Are you ready?"
```

the kernel can configure the device to generate an interrupt.

```text
CPU
 │
 │ configure device
 ▼
Device
 │
 │ work...
 │
 │ interrupt
 ▼
PIC / APIC
 │
 ▼
CPU
 │
 ▼
Interrupt Handler
```

This allows the CPU to perform other work while the device operates.

For example:

```text
Device
   │
   │ data ready
   ▼
IRQ
   │
   ▼
Interrupt handler
   │
   ▼
Read device data
```

This is a major part of operating-system driver design.

---

# 12. DMA — Direct Memory Access

For large amounts of data, transferring everything through the CPU can be inefficient.

Without DMA:

```text
Device → CPU → RAM
Device → CPU → RAM
Device → CPU → RAM
Device → CPU → RAM
```

With DMA:

```text
              CPU
               │
               │ configure
               ▼
            Device
               │
               │ DMA transfer
               ▼
              RAM
```

The CPU tells the device:

```text
Destination = RAM address
Length      = number of bytes
Operation   = read/write
```

The device can then transfer the data directly to memory.

DMA is especially important for:

* Storage controllers
* Network cards
* Audio devices
* USB
* GPUs

---

# 13. Typical Device Driver Interaction

A real driver may combine several patterns.

For example:

```text
                 Driver
                    │
        ┌───────────┼───────────┐
        │           │           │
     Control      Status       Data
        │           │           │
        └───────────┼───────────┘
                    │
                  Device
                    │
                 Interrupt
                    │
                    ▼
              Interrupt Handler
                    │
                    ▼
                  Driver
                    │
                    ▼
                   DMA
                    │
                    ▼
                   RAM
```

A typical sequence could be:

```text
1. Configure device
2. Start operation
3. Device performs work
4. Device updates status
5. Device generates interrupt
6. CPU executes interrupt handler
7. Driver checks status
8. Driver processes data
9. DMA transfers data to/from RAM
10. Driver acknowledges/completes the operation
```

---

# 14. Important Terminology

### Port

An address in the x86 I/O address space.

```c
outb(port, value);
```

### Register

A small hardware storage location used for:

* Configuration
* Control
* Status
* Data

### Command

An instruction sent to a device.

```text
START
RESET
ENABLE
DISABLE
```

### Data

The actual value being transferred.

### Status

Information about the current state of the device.

```text
READY
BUSY
ERROR
DONE
```

### Index

A value used to select which internal register should be accessed.

### MMIO

Device registers mapped into the CPU's memory address space.

### FIFO

A first-in-first-out data buffer.

### Interrupt

A mechanism allowing hardware to notify the CPU that an event occurred.

### DMA

A mechanism allowing a device to transfer data directly to or from RAM.

---

# 15. The Main Patterns to Remember

The most useful patterns to recognize while developing a kernel are:

```text
1. Command + Data

   Command → What operation?
   Data    → What value?


2. Index + Data

   Index → Which register?
   Data  → What value?


3. Status + Data

   Status → Is the device ready?
   Data   → Actual data


4. Control + Status + Data

   Control → Tell device what to do
   Status  → Check device state
   Data    → Transfer data


5. MMIO

   Memory address → Device register


6. FIFO / Queue

   Device ↔ Buffer ↔ CPU


7. Interrupt-driven I/O

   Device → IRQ → CPU → Handler


8. DMA

   Device ↔ RAM
        ↑
       CPU configures
```

---

# 16. The Most Important Rule

Do not assume that a port or register has a particular meaning because of its position.

For example:

```text
0x20 → Command
0x21 → Data
```

is true for the legacy PIC.

But:

```text
0x3D4 → Index
0x3D5 → Data
```

is true for a particular VGA interface.

The correct approach is always:

```text
Hardware specification
        │
        ▼
Register / Port layout
        │
        ▼
Driver implementation
        │
        ▼
Kernel abstraction
```

The **hardware documentation is the source of truth** for what each port, register, bit, and value means.
