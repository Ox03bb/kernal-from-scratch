# Programmable Interrupt Controller (PIC)

## 1. Overview

The Programmable Interrupt Controller (PIC) is a hardware component responsible for receiving interrupt requests from hardware devices and delivering them to the CPU.

In a 32-bit x86 system, the traditional PIC is the **8259A Programmable Interrupt Controller**.

The PIC sits between hardware devices and the CPU:

    Hardware Device
          |
          | IRQ
          v
        +-----+
        | PIC |
        +-----+
          |
          | Interrupt
          v
         CPU
          |
          v
         IDT
          |
          v
       Handler

The PIC does not execute the interrupt handler itself.

Its main responsibility is to:

1. Receive hardware interrupt requests.
2. Determine which IRQ was triggered.
3. Decide whether the IRQ is masked.
4. Send an interrupt request to the CPU.
5. Provide the corresponding interrupt vector to the CPU.
6. Receive an End Of Interrupt (EOI) signal after the interrupt is handled.

---

# 2. What is an IRQ?

IRQ stands for **Interrupt Request**.

A hardware device can use an IRQ to notify the CPU that it needs attention.

Examples:

    Timer       -> IRQ0
    Keyboard    -> IRQ1
    Serial port -> IRQ4

An IRQ is a hardware-level concept.

It is different from an interrupt vector.

For example:

    IRQ1
      |
      | PIC maps IRQ1
      v
    Vector 33
      |
      v
    IDT[33]
      |
      v
    Keyboard handler

So:

- IRQ = hardware interrupt request number.
- Vector = number used to select an IDT entry.
- IDT entry = contains the address and configuration of the handler.

---

# 3. The 8259A PIC

The traditional x86 architecture uses the Intel 8259A PIC.

A system normally has two PICs:

    +-------------+
    | Master PIC  |
    |    8259A    |
    +-------------+
      IRQ0 - IRQ7
          |
          | IRQ2
          v
    +-------------+
    |  Slave PIC  |
    |    8259A    |
    +-------------+
      IRQ8 - IRQ15

The master PIC handles IRQ0 through IRQ7.

The slave PIC handles IRQ8 through IRQ15.

The slave PIC is connected to IRQ2 of the master PIC.

This gives the system 16 hardware IRQ lines:

    IRQ0  -> Timer
    IRQ1  -> Keyboard
    IRQ2  -> Cascade connection to slave PIC
    IRQ3  -> Serial port
    IRQ4  -> Serial port
    IRQ5  -> Available / legacy device
    IRQ6  -> Floppy disk
    IRQ7  -> Available / legacy device

    IRQ8  -> RTC
    IRQ9  -> Available
    IRQ10 -> Available
    IRQ11 -> Available
    IRQ12 -> PS/2 mouse
    IRQ13 -> FPU
    IRQ14 -> Primary ATA
    IRQ15 -> Secondary ATA

These assignments are historical and can vary depending on the hardware.

---

# 4. Why do we remap the PIC?

When the CPU starts, the traditional PIC normally uses interrupt vectors that conflict with CPU exceptions.

The default mapping is approximately:

    IRQ0 -> Vector 8
    IRQ1 -> Vector 9
    IRQ2 -> Vector 10
    ...

But CPU exceptions already occupy vectors:

    Vector 0  -> Divide Error
    Vector 1  -> Debug
    Vector 2  -> NMI
    ...
    Vector 8  -> Double Fault
    ...

Therefore:

    IRQ0 -> Vector 8

would conflict with:

    Vector 8 -> Double Fault

This is a problem.

The solution is to **remap the PIC**.

A common mapping is:

    Master PIC:

    IRQ0 -> Vector 32
    IRQ1 -> Vector 33
    IRQ2 -> Vector 34
    IRQ3 -> Vector 35
    IRQ4 -> Vector 36
    IRQ5 -> Vector 37
    IRQ6 -> Vector 38
    IRQ7 -> Vector 39

    Slave PIC:

    IRQ8  -> Vector 40
    IRQ9  -> Vector 41
    IRQ10 -> Vector 42
    IRQ11 -> Vector 43
    IRQ12 -> Vector 44
    IRQ13 -> Vector 45
    IRQ14 -> Vector 46
    IRQ15 -> Vector 47

Therefore:

    CPU exceptions -> vectors 0-31

    Hardware IRQs  -> vectors 32-47

This gives the two groups separate ranges.

---

# 5. IRQ vs Interrupt Vector

These two concepts are important.

An IRQ identifies a hardware interrupt request:

    IRQ1

After the PIC maps it, the CPU receives a vector:

    Vector 33

The CPU then uses that vector as an index into the IDT:

    IDT[33]

Therefore:

    Keyboard
       |
       | IRQ1
       v
      PIC
       |
       | Vector 33
       v
      CPU
       |
       v
    IDT[33]
       |
       v
    Keyboard ISR

---

# 6. PIC Ports

The traditional 8259A PIC is programmed through I/O ports.

The master PIC uses:

    0x20  -> Command
    0x21  -> Data

The slave PIC uses:

    0xA0  -> Command
    0xA1  -> Data

So:

    Master:
        Command = 0x20
        Data    = 0x21

    Slave:
        Command = 0xA0
        Data    = 0xA1

The kernel communicates with these ports using the x86 `in` and `out` instructions.

For example:

    outb(0x20, command);

means:

    Send command to the master PIC.

---

# 7. PIC Interrupt Mask

The PIC has an Interrupt Mask Register (IMR).

The mask determines which IRQs are allowed.

There are 8 mask bits per PIC.

For the master:

    Bit 0 -> IRQ0
    Bit 1 -> IRQ1
    Bit 2 -> IRQ2
    ...
    Bit 7 -> IRQ7

For the slave:

    Bit 0 -> IRQ8
    Bit 1 -> IRQ9
    ...
    Bit 7 -> IRQ15

A bit value of:

    0 -> IRQ enabled

    1 -> IRQ masked

For example:

    11111110

means:

    IRQ0 -> enabled
    IRQ1 -> disabled
    IRQ2 -> disabled
    ...
    IRQ7 -> disabled

The kernel can change the mask to enable or disable individual hardware interrupts.

---

# 8. Interrupt Acknowledgement

When a device raises an IRQ:

    Device
       |
       | IRQ
       v
      PIC
       |
       v
      CPU

The CPU eventually executes the corresponding interrupt handler.

After the kernel finishes handling the interrupt, it must tell the PIC:

    "I finished handling this interrupt."

This is called **End Of Interrupt (EOI)**.

The kernel sends an EOI command to the PIC.

For the master PIC:

    outb(0x20, 0x20);

For an interrupt coming from the slave PIC, an EOI must normally be sent to both:

    Slave PIC
        |
        v
    Master PIC

    outb(0xA0, 0x20);
    outb(0x20, 0x20);

Without the appropriate EOI, the PIC may not deliver subsequent interrupts correctly.

---

# 9. PIC Initialization

The kernel normally initializes the PIC before enabling hardware interrupts.

The general process is:

    1. Disable interrupts
           |
           v
    2. Initialize master PIC
           |
           v
    3. Initialize slave PIC
           |
           v
    4. Remap IRQs
           |
           v
    5. Configure interrupt masks
           |
           v
    6. Create IDT entries for IRQ handlers
           |
           v
    7. Enable interrupts with STI

The exact PIC initialization sequence uses Initialization Command Words (ICWs).

---

# 10. Initialization Command Words

The 8259A is initialized using several command words.

The main ones are:

    ICW1
    ICW2
    ICW3
    ICW4

Their roles are roughly:

    ICW1 -> Begin initialization

    ICW2 -> Set interrupt vector offset

    ICW3 -> Configure master/slave relationship

    ICW4 -> Configure operating mode

For example:

    Master offset = 32
    Slave offset  = 40

After initialization:

    Master:
        IRQ0 -> 32
        IRQ1 -> 33
        ...
        IRQ7 -> 39

    Slave:
        IRQ8  -> 40
        ...
        IRQ15 -> 47

---

# 11. PIC and IDT Relationship

The PIC and IDT have different responsibilities.

The PIC determines:

    "Which hardware IRQ happened?"

The PIC then provides a vector.

The IDT determines:

    "Which handler should the CPU execute for this vector?"

For example, a keyboard interrupt:

    Keyboard
       |
       | IRQ1
       v
    Master PIC
       |
       | Vector 33
       v
      CPU
       |
       | IDT[33]
       v
    keyboard_isr()
       |
       v
    keyboard driver

Therefore:

    PIC -> hardware interrupt routing

    IDT -> CPU interrupt dispatching

---

# 12. PIC Is Programmable

The word "Programmable" means that the kernel can configure the PIC.

The kernel can configure:

    - Interrupt vector offsets
    - IRQ masks
    - Master/slave relationship
    - Operating mode
    - Interrupt acknowledgement

For example:

    PIC_remap(32, 40);

can conceptually mean:

    Master IRQs -> 32-39
    Slave IRQs  -> 40-47

---

# 13. PIC vs APIC

The 8259A PIC is the traditional interrupt controller.

Modern x86 systems generally use the **APIC architecture** instead.

The important distinction is:

    PIC
      |
      v
    Legacy interrupt controller

    APIC
      |
      v
    Modern interrupt controller architecture

For a small educational 32-bit kernel, implementing the 8259A PIC is useful because it teaches:

    IRQs
    Interrupt vectors
    IDT
    I/O ports
    Interrupt masking
    EOI
    Hardware interrupt handling

Later, the kernel can be extended to support APIC.

---

# 14. Complete Interrupt Flow

The complete flow for a hardware interrupt is:

    Hardware device
          |
          | IRQ
          v
    +-------------+
    |     PIC     |
    +-------------+
          |
          | Interrupt vector
          v
        +-----+
        | CPU |
        +-----+
          |
          | vector
          v
    +-------------+
    |     IDT     |
    +-------------+
          |
          | handler address
          v
    +-------------+
    |     ISR     |
    +-------------+
          |
          v
    Device driver
          |
          v
        EOI
          |
          v
        PIC

---

# 15. Example: Keyboard Interrupt

Suppose the user presses a key.

The keyboard controller generates:

    IRQ1

The PIC has been configured so:

    IRQ1 -> Vector 33

The CPU receives vector 33.

The CPU looks at:

    IDT[33]

That IDT entry contains the address of the keyboard ISR.

Therefore:

    Keyboard
       |
       | IRQ1
       v
      PIC
       |
       | 33
       v
      CPU
       |
       | IDT[33]
       v
    keyboard_isr()
       |
       v
    keyboard driver
       |
       v
       EOI
       |
       v
      PIC

---

# 16. Implementation Order in Our Kernel

The implementation should follow this order:

    IDT
     |
     v
    ISR mechanism
     |
     v
    PIC driver
     |
     v
    PIC remapping
     |
     v
    IRQ handlers
     |
     v
    Timer IRQ0
     |
     v
    Keyboard IRQ1
     |
     v
    Enable interrupts

The first hardware interrupt we should normally test is:

    IRQ0 -> Timer

Then:

    IRQ1 -> Keyboard

---

# 17. Summary

The PIC is responsible for managing hardware interrupt requests.

Important concepts:

    IRQ
        Hardware interrupt request.

    PIC
        Hardware interrupt controller.

    Vector
        Number used by the CPU to select an IDT entry.

    IDT
        Table containing interrupt descriptors.

    ISR
        Code executed to handle an interrupt.

    EOI
        Signal sent to the PIC after handling an IRQ.

    Mask
        Controls whether an IRQ is enabled or disabled.

The overall relationship is:

    Device
      |
      | IRQ
      v
     PIC
      |
      | Vector
      v
     CPU
      |
      | IDT lookup
      v
     ISR
      |
      | EOI
      v
     PIC