# x86-64 Architecture — Complete Reference (Part II)

> Part II of a two-part reference. Part I covered the Intel 8086 (1978). This part
> covers **x86-64** (also called AMD64, Intel 64, or x64) — the 64-bit extension of the
> x86 family — and closes with a full side-by-side comparison against the 8086.

---

## Table of Contents

- [x86-64 Architecture — Complete Reference (Part II)](#x86-64-architecture--complete-reference-part-ii)
  - [Table of Contents](#table-of-contents)
  - [1. Overview](#1-overview)
  - [2. High-Level Architecture](#2-high-level-architecture)
    - [2.1 Front End (Fetch/Decode)](#21-front-end-fetchdecode)
    - [2.2 Out-of-Order Execution Core](#22-out-of-order-execution-core)
    - [2.3 Memory Subsystem (Caches, MMU)](#23-memory-subsystem-caches-mmu)
  - [3. Register Set](#3-register-set)
    - [3.1 General-Purpose Registers](#31-general-purpose-registers)
    - [3.2 Instruction Pointer and FLAGS](#32-instruction-pointer-and-flags)
    - [3.3 Segment Registers in Long Mode](#33-segment-registers-in-long-mode)
    - [3.4 SIMD Registers (SSE/AVX/AVX-512)](#34-simd-registers-sseavxavx-512)
    - [3.5 Full Register Map Diagram](#35-full-register-map-diagram)
  - [4. Memory Model: Flat Paging Instead of Segmentation](#4-memory-model-flat-paging-instead-of-segmentation)
    - [4.1 Virtual Address Translation](#41-virtual-address-translation)
    - [4.2 Page Table Levels (4-level / 5-level Paging)](#42-page-table-levels-4-level--5-level-paging)
    - [4.3 Canonical Addresses](#43-canonical-addresses)
  - [5. Buses and Interconnects](#5-buses-and-interconnects)
    - [5.1 From a Shared Bus to Point-to-Point Links](#51-from-a-shared-bus-to-point-to-point-links)
    - [5.2 Integrated Memory Controller](#52-integrated-memory-controller)
  - [6. Addressing Modes](#6-addressing-modes)
  - [7. Operating Modes](#7-operating-modes)
  - [8. Instruction Pipeline and Superscalar Execution](#8-instruction-pipeline-and-superscalar-execution)
  - [9. Interrupt and Exception System](#9-interrupt-and-exception-system)
  - [10. Calling Convention (System V AMD64 ABI)](#10-calling-convention-system-v-amd64-abi)
  - [11. Quick Reference Tables](#11-quick-reference-tables)
  - [12. Part I vs Part II: 8086 vs x86-64 — Full Comparison](#12-part-i-vs-part-ii-8086-vs-x86-64--full-comparison)
  - [13. Resources](#13-resources)

---

## 1. Overview

**x86-64** is the 64-bit instruction set architecture that extends the original 8086/x86
lineage. It was designed by **AMD** and first shipped in the **Opteron/Athlon 64**
processors (2003) under the name **AMD64**; Intel later licensed the same architecture
and calls its implementation **Intel 64** (originally "EM64T" / "IA-32e"). Both are
binary-compatible with each other and are collectively referred to as **x86-64** or
**x64**.

| Property | Value |
|---|---|
| Data width (native integer / GPRs) | 64 bits |
| Address bus (virtual, architectural) | 64-bit registers, but only 48–57 bits actually used |
| Physical address space (typical) | up to 2⁵² bytes (implementation-defined, e.g. 46–52 bits) |
| Virtual address space | 256 TiB (48-bit) or 128 PiB (57-bit, with 5-level paging) |
| Register width | 64-bit GPRs; 128/256/512-bit SIMD registers |
| General-purpose registers | 16 (up from 8 in 32-bit x86, 4 "main" ones in the 8086) |
| Instruction fetch/decode | Superscalar, out-of-order, deeply pipelined (14–20+ stages depending on microarchitecture) |
| Package | Varies (LGA/BGA, thousands of pins/balls) |
| Transistor count | Billions (varies wildly by SKU and integrated components) |
| Clock speeds (typical modern) | 2–5.5+ GHz, multi-core |

Unlike the 8086 — a single monolithic execution pipeline described almost completely by
its BIU/EU split — a modern x86-64 core is best understood as a **pipeline of
specialized stages** feeding an **out-of-order execution engine**, wrapped in a memory
hierarchy of multiple cache levels and a hardware **paging unit (MMU)** that replaces
8086-style segmentation entirely for normal addressing purposes.

---

## 2. High-Level Architecture


### 2.1 Front End (Fetch/Decode)

The front end no longer looks anything like the 8086's simple 6-byte FIFO. Its jobs:

- Predict branch outcomes far ahead of execution using dedicated **branch predictor**
  hardware (pattern history tables, branch target buffers, return stack predictors).
- Fetch instruction bytes from the **L1 instruction cache**, not directly from main
  memory.
- **Decode** variable-length x86 instructions into one or more fixed-format internal
  **micro-operations (μops)** that the back end actually executes.
- Cache decoded μops in a **micro-op cache** so hot loops can skip the decoder
  entirely on repeat execution.

### 2.2 Out-of-Order Execution Core

Where the 8086's EU executed instructions strictly in program order, a modern x86-64
core executes μops **out of order**, restricted only by true data dependencies:

- A **Reorder Buffer (ROB)** tracks every in-flight μop and guarantees instructions
  still *retire* (commit their results) in original program order, so the programmer-
  visible behavior stays sequential even though internal execution isn't.
- **Reservation stations / scheduler** hold μops until their input operands are ready,
  then dispatch them to whichever **execution port** is free.
- Multiple **execution ports** run in parallel: several integer ALUs, address-generation
  units (AGUs) for loads/stores, and wide SIMD/FPU units, allowing several instructions
  to complete in the same clock cycle (superscalar execution).
- **Register renaming** maps the 16 architectural GPRs onto a much larger pool of
  physical registers, eliminating false dependencies between unrelated instructions
  that happen to reuse the same architectural register name.

### 2.3 Memory Subsystem (Caches, MMU)

There is no single "BIU" generating a segment×16+offset address anymore. Instead:

- Every virtual address a program uses passes through the **MMU**, which walks
  hardware **page tables** (cached in the **TLB**, Translation Lookaside Buffer) to
  produce a physical address.
- A multi-level cache hierarchy (**L1, L2, per-core; L3 shared**) sits between the core
  and DRAM, since DRAM latency (hundreds of cycles) would otherwise stall a multi-GHz
  core constantly.
- An **integrated memory controller** on the same die talks directly to DRAM — the
  8086's external, chipset-mediated memory access has been absorbed into the CPU
  package itself.

---

## 3. Register Set

### 3.1 General-Purpose Registers

x86-64 keeps the *names* of the original 8086 registers but widens them to 64 bits and
adds eight entirely new ones (`R8`–`R15`):

| 64-bit | 32-bit (low half) | 16-bit (low half) | 8-bit (low half) | Notes |
|---|---|---|---|---|
| `RAX` | `EAX` | `AX` | `AL` | Accumulator |
| `RBX` | `EBX` | `BX` | `BL` | Base |
| `RCX` | `ECX` | `CX` | `CL` | Counter |
| `RDX` | `EDX` | `DX` | `DL` | Data |
| `RSI` | `ESI` | `SI` | `SIL` | Source index |
| `RDI` | `EDI` | `DI` | `DIL` | Destination index |
| `RBP` | `EBP` | `BP` | `BPL` | Base pointer |
| `RSP` | `ESP` | `SP` | `SPL` | Stack pointer |
| `R8`–`R15` | `R8D`–`R15D` | `R8W`–`R15W` | `R8B`–`R15B` | New in x86-64, no 8086 equivalent |

A quirk inherited from 32-bit x86: writing to a 32-bit sub-register (e.g. `EAX`)
**zero-extends** into the full 64-bit register, but writing to a 16- or 8-bit
sub-register leaves the upper bits of the 64-bit register unchanged.

### 3.2 Instruction Pointer and FLAGS

- `RIP` (64-bit instruction pointer) replaces the 8086's 16-bit `IP`. Crucially,
  `RIP`-relative addressing is a first-class addressing mode in x86-64 — something the
  8086 had no equivalent of — which makes position-independent code far more efficient.
- `RFLAGS` extends `FLAGS` to 64 bits, but only the low 32 bits carry defined flags in
  practice (carry, zero, sign, overflow, etc. — the same status flags the 8086 already
  had, plus later additions like `VM`, `VIF`, `ID`).

### 3.3 Segment Registers in Long Mode

`CS`, `DS`, `SS`, `ES`, `FS`, `GS` still exist, but in 64-bit ("long") mode their
segmentation behavior is almost entirely **disabled**:

- `DS`, `ES`, `SS` are treated as if base = 0 and no limit checking — pure legacy
  placeholders.
- `CS` still carries the code-segment descriptor (needed for privilege level and the
  64-bit-mode flag) but its base is likewise ignored for addressing.
- `FS` and `GS` are the exception: they retain a programmable **base address** and are
  actively used today, typically for **thread-local storage (TLS)** — a role that has
  nothing to do with the 8086's original segmentation-for-more-memory purpose.

### 3.4 SIMD Registers (SSE/AVX/AVX-512)

The 8086 had no SIMD registers at all. x86-64 processors add a large, separate register
file for vectorized floating-point and integer work:

| Register set | Width | Introduced with |
|---|---|---|
| `XMM0`–`XMM15` | 128-bit | SSE / SSE2 |
| `YMM0`–`YMM15` | 256-bit (lower 128 bits alias `XMM`) | AVX |
| `ZMM0`–`ZMM31` | 512-bit (lower halves alias `YMM`/`XMM`) | AVX-512 |

These allow one instruction to operate on many data elements at once (e.g. eight
32-bit floats packed into one 256-bit `YMM` register) — a form of parallelism entirely
absent from the 8086's scalar-only ALU.

### 3.5 Full Register Map Diagram

```
64-bit:  RAX RBX RCX RDX RSI RDI RBP RSP R8 R9 R10 R11 R12 R13 R14 R15   RIP  RFLAGS
          │   │   │   │   │   │   │   │
32-bit:  EAX EBX ECX EDX ESI EDI EBP ESP   (R8D..R15D for the new registers)
          │   │   │   │
16-bit:  AX  BX  CX  DX   (SI, DI, BP, SP also addressable at 16 bits — legacy 8086 view)
          │   │   │   │
 8-bit:  AH/AL BH/BL CH/CL DH/DL   (only AX-DX keep the historic high/low byte split)

Segment (mostly vestigial): CS  DS  SS  ES  FS*  GS*     (*FS/GS keep a real base address)

SIMD:    XMM0-15 (128b) ⊂ YMM0-15 (256b) ⊂ ZMM0-31 (512b)
```

---

## 4. Memory Model: Flat Paging Instead of Segmentation

This is the single biggest architectural break from the 8086. Where Part I's Section 4
covered `segment × 16 + offset`, x86-64 abandons segmented addressing for a **flat,
paged virtual memory model** enforced entirely by the MMU.

### 4.1 Virtual Address Translation

Every memory access uses a single 64-bit virtual address, which the CPU's paging
hardware translates to a physical address:

```
64-bit Virtual Address (4-level paging, 48 bits used)
┌────────────┬─────────┬─────────┬─────────┬─────────┬────────────┐
│ sign-ext.  │ PML4    │ PDPT    │ PD      │ PT      │ Page offset│
│ bits 63-48 │ 9 bits  │ 9 bits  │ 9 bits  │ 9 bits  │  12 bits   │
└────────────┴─────────┴─────────┴─────────┴─────────┴────────────┘
                  │          │          │          │          │
                  ▼          ▼          ▼          ▼          ▼
             walks 4 levels of page tables in memory (cached by the TLB)
                  to produce a physical page frame + offset
```

### 4.2 Page Table Levels (4-level / 5-level Paging)

| Level | Structure | Entries | Covers |
|---|---|---|---|
| 4 (top) | PML4 (Page Map Level 4) | 512 | Entire 256 TiB (48-bit) address space |
| 3 | PDPT (Page-Directory-Pointer Table) | 512 | 512 GiB per entry |
| 2 | PD (Page Directory) | 512 | 1 GiB per entry (or maps a 2 MiB huge page directly) |
| 1 (bottom) | PT (Page Table) | 512 | 2 MiB per entry (or maps a single 4 KiB page) |

Newer CPUs support an optional **5-level paging** mode (adding a PML5 level) to extend
the virtual address space from 48 bits (256 TiB) to 57 bits (128 PiB) for very
large-memory servers.

### 4.3 Canonical Addresses

Because only 48 (or 57) of the 64 virtual address bits are actually implemented, the
unused upper bits must all equal bit 47 (or bit 56) — a requirement called being
**canonical**. A non-canonical address triggers a general-protection fault rather than
silently wrapping, unlike the 8086, where all 20 address-bus bits were always
meaningful (and where segment wraparound was a well-known, exploitable quirk rather
than a fault).

---

## 5. Buses and Interconnects

### 5.1 From a Shared Bus to Point-to-Point Links

The 8086 exposed a single multiplexed address/data bus that every device on the board
shared and arbitrated for. Modern x86-64 systems instead use dedicated, high-speed
**point-to-point serial links**:

| Link | Purpose | Rough analogy to 8086 bus |
|---|---|---|
| **PCIe** (PCI Express) | CPU ↔ GPU, storage, expansion cards | Successor to the address/data/control bus, but serial and per-device |
| **Intel UPI** / **AMD Infinity Fabric** | CPU ↔ CPU (multi-socket), CPU ↔ internal chiplets | No 8086 equivalent — the 8086 was always a single chip |
| **DMI** | CPU ↔ chipset (Intel) | Loosely analogous to the old bus-to-peripheral link |

### 5.2 Integrated Memory Controller

The 8086 relied on external logic to drive DRAM refresh and timing. Modern x86-64 CPUs
integrate the **memory controller** directly on-die, talking straight to DDR4/DDR5
DIMMs — eliminating a hop that used to go through a separate "northbridge" chip, let
alone the fully external memory interface the 8086 required.

---

## 6. Addressing Modes

x86-64 keeps the 8086's basic addressing-mode vocabulary (register, immediate, direct,
register-indirect, base+index, base+index+displacement) and adds:

| Addressing mode | 8086 | x86-64 |
|---|---|---|
| Register | Yes (`AX`, `BX`, …) | Yes (`RAX`, `R8`, …) |
| Immediate | Yes | Yes, including 64-bit immediates for some instructions |
| Direct / displacement-only | Yes (with segment override) | Yes (flat, no segment override needed) |
| Base + index + displacement | Yes (`[BX+SI+disp]`) | Yes, generalized to any GPR (`[RAX+RCX*4+disp]`) |
| Scaled index (×2/×4/×8) | **No** | **Yes** — SIB (Scale-Index-Base) byte encoding |
| `RIP`-relative | **No** | **Yes** — operand address relative to the next instruction |
| Segment override prefix | Central to addressing (`ES:`, `SS:`, …) | Rare; mainly `FS:`/`GS:` for TLS |

The **SIB byte** and **RIP-relative addressing** are the two genuinely new addressing
capabilities that didn't exist in any form on the 8086.

---

## 7. Operating Modes

Unlike the 8086, which had exactly one operating mode, x86-64 CPUs support several,
selected by the operating system at runtime:

| Mode | Register width | Typical use |
|---|---|---|
| **Real mode** | 16-bit | Legacy boot-time compatibility, mimics original 8086 behavior (segment×16+offset) |
| **Protected mode** | 32-bit | Classic 32-bit x86 OSes and applications |
| **Long mode — 64-bit submode** | 64-bit | Native 64-bit OS and applications |
| **Long mode — compatibility submode** | 32-bit | Running unmodified 32-bit apps under a 64-bit OS |
| **Virtual-8086 mode** | 16-bit | Running old 16-bit DOS-era software inside a 32-bit protected-mode OS |

Notably, an x86-64 CPU powers on **in real mode**, behaving almost exactly like an
8086 (with a 20-bit-style address wraparound available for compatibility), and the boot
loader/OS explicitly switches it up through protected mode into long mode. This is why
"the 8086 architecture" is not just historical trivia — it's the literal power-on state
of every x86-64 PC.

---

## 8. Instruction Pipeline and Superscalar Execution

Where Part I's Section 11 showed simple two-stage overlap (BIU fetch / EU execute),
a modern x86-64 pipeline has many more stages and issues multiple instructions per
cycle:

```
Time ───────────────────────────────────────────────────────────────►

Fetch:   [I1][I2][I3][I4][I5][I6]...
Decode:      [I1][I2][I3][I4][I5]...
Rename:          [I1][I2][I3][I4]...
Dispatch:            [I1,I2 →port0/1][I3 →port2]...    ◄── multiple μops issue per cycle
Execute:                 [I1][I2][I3]...                    (out of order, on separate ports)
Retire:                       [I1][I2][I3]...                (forced back into program order)
```

- **Superscalar**: several instructions can be fetched, decoded, and executed in the
  same clock cycle (versus one instruction moving through the 8086's pipeline at a
  time).
- **Out-of-order execution**: instructions may execute before earlier ones if their
  operands are ready first; the ROB restores program order only at retirement.
- **Speculative execution**: branch predictions let the CPU execute *past* an
  unresolved branch; if the prediction is wrong, speculatively executed work is
  discarded (a modern, much more elaborate cousin of the 8086's simple queue flush on
  a taken jump).
- **Deeper pipelines**: 14–20+ stages is typical, versus the 8086's much shallower
  fetch/decode/execute overlap.

---

## 9. Interrupt and Exception System

x86-64 keeps the same conceptual vector-table idea from the 8086 but relocates and
extends it:

- The 256-entry table becomes the **Interrupt Descriptor Table (IDT)**, an
  OS-configurable structure (versus the 8086's fixed table at physical address `0`).
  Each entry is a **gate descriptor** (16 bytes in long mode) rather than a raw 4-byte
  far pointer.
- Interrupt/exception delivery still saves a return context and can switch execution
  context, but now also saves/restores full 64-bit state and can switch privilege
  rings (0–3) and even a dedicated **Interrupt Stack Table (IST)** stack for critical
  events like double faults or NMIs.
- New exception types that didn't exist on the 8086 include **page faults** (from the
  paging system in Section 4) and **general-protection faults** (from privilege and
  canonical-address checks).
- `NMI` and maskable external interrupts (now typically routed through an **Advanced
  Programmable Interrupt Controller, APIC**, one per core) still map onto the same
  basic maskable/non-maskable split the 8086 introduced.

---

## 10. Calling Convention (System V AMD64 ABI)

The 8086 had no standardized calling convention — compilers picked their own
push-everything-on-the-stack scheme. x86-64's abundance of general-purpose registers
enabled a register-based calling convention (Linux/macOS use the **System V AMD64
ABI**; Windows uses a similar but distinct convention):

| Argument # | Register (System V AMD64) |
|---|---|
| 1st integer/pointer arg | `RDI` |
| 2nd | `RSI` |
| 3rd | `RDX` |
| 4th | `RCX` |
| 5th | `R8` |
| 6th | `R9` |
| 7th+ | Stack |
| Return value | `RAX` (and `RDX` for 128-bit returns) |
| Floating-point args | `XMM0`–`XMM7` |

Passing the first six integer arguments in registers instead of on the stack is a
direct consequence of x86-64 having eight more GPRs than 32-bit x86 (which itself had
twice as many as the 8086's four general-purpose registers).

---

## 11. Quick Reference Tables

**Register count growth across the family**

| Architecture | General-purpose registers | Register width |
|---|---|---|
| 8086 | 4 (`AX`,`BX`,`CX`,`DX`) + 4 pointer/index | 16-bit |
| 32-bit x86 (IA-32) | 8 (`EAX`...`EDI`) | 32-bit |
| x86-64 | 16 (`RAX`...`R15`) | 64-bit |

**Address space growth**

| Architecture | Address bus / addressable range |
|---|---|
| 8086 | 20-bit → 1 MiB |
| 32-bit x86 | 32-bit → 4 GiB |
| x86-64 (48-bit virtual) | 256 TiB virtual, up to ~64 TiB–4 PiB physical (implementation-defined) |
| x86-64 (57-bit virtual, 5-level paging) | 128 PiB virtual |

**Conceptual mapping, 8086 → x86-64**

| 8086 concept | x86-64 equivalent / replacement |
|---|---|
| BIU/EU split | Front end / out-of-order back end |
| 6-byte instruction queue | Deep pipeline + micro-op cache |
| Segmentation (`seg×16+offset`) | Flat 64-bit virtual addressing + paging (MMU/TLB) |
| Shared multiplexed bus | Point-to-point links (PCIe, UPI/Infinity Fabric) + integrated memory controller |
| Fixed IVT at address 0 | Relocatable IDT with gate descriptors |
| No SIMD | SSE/AVX/AVX-512 (`XMM`/`YMM`/`ZMM`) |
| Single operating mode | Real / Protected / Long (64-bit & compatibility) / Virtual-8086 |

---

## 12. Part I vs Part II: 8086 vs x86-64 — Full Comparison

| Dimension | Intel 8086 (1978) | x86-64 (2003–present) |
|---|---|---|
| **Data width** | 16-bit | 64-bit (with 8/16/32-bit legacy sub-modes) |
| **Address width** | 20-bit (1 MiB) | 48–57-bit virtual (256 TiB–128 PiB); physical implementation-defined |
| **Memory model** | Segmented (`segment×16+offset`) | Flat, paged virtual memory (MMU + TLB) |
| **GPR count** | 4 main + 4 pointer/index (8 total, all 16-bit) | 16, all 64-bit, freely sub-addressable |
| **Segment registers** | 4, essential for every address | 6, mostly vestigial except `FS`/`GS` (TLS base) |
| **Execution model** | In-order, 2-stage overlap (BIU/EU) | Out-of-order, superscalar, speculative, deeply pipelined |
| **SIMD/vector support** | None | SSE/AVX/AVX-512, 128–512-bit registers |
| **Instruction issue** | ~1 instruction at a time | Multiple μops per cycle across several execution ports |
| **Cache hierarchy** | None (direct memory access) | L1/L2/L3 multi-level caches, on-die |
| **Memory controller** | Fully external | Integrated on-die |
| **System bus** | Single shared multiplexed bus | Point-to-point links (PCIe, UPI/Infinity Fabric) |
| **Interrupt table** | Fixed IVT at physical address 0, 4-byte far-pointer entries | Relocatable IDT, 16-byte gate descriptors, privilege-aware |
| **New fault types** | Divide error, minimal protection faults | + Page fault, general-protection fault, and more (full protection-ring model) |
| **Operating modes** | One (native mode only) | Real, Protected, Long (64-bit + compatibility), Virtual-8086 |
| **Calling convention** | Ad hoc, stack-based, compiler-specific | Standardized register-based ABI (System V AMD64 / Microsoft x64) |
| **Addressing modes** | Register, immediate, direct, base+index+disp | All of the above + scaled index (SIB) + RIP-relative |
| **Multiprocessing** | Not supported natively (needed 8089/8087 + max mode) | Native multi-core, multi-socket, cache-coherent |
| **Transistor count** | ~29,000 | Billions |
| **Power-on state** | N/A (it *is* the native state) | Boots in real mode, mimicking 8086 behavior, before switching to long mode |

**The throughline:** x86-64 did not discard the 8086 — it kept the same register
names, the same basic instruction philosophy, the same maskable/non-maskable interrupt
split, and even the same power-on behavior, while replacing the parts that didn't scale
(segmentation, in-order single-issue execution, a shared external bus) with mechanisms
suited to gigahertz clock speeds, gigabyte-to-terabyte memory, and multi-core silicon.
Understanding the 8086 (Part I) is what makes the "why" behind x86-64's design choices
(Part II) legible — nearly every x86-64 feature exists specifically to remove a
limitation the 8086 had.

---

## 13. Resources

The following sources were used to research, verify, and cross-check the technical
details in this document:

1. AMD — *AMD64 Architecture Programmer's Manual, Volume 1: Application Programming*.
   https://www.amd.com/en/search/documentation/hub.html
2. AMD — *AMD64 Architecture Programmer's Manual, Volume 2: System Programming* (paging, long mode, interrupts).
   https://www.amd.com/en/search/documentation/hub.html
3. Intel Corporation — *Intel 64 and IA-32 Architectures Software Developer's Manual, Volume 1: Basic Architecture*.
   https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html
4. Intel Corporation — *Intel 64 and IA-32 Architectures Software Developer's Manual, Volume 3: System Programming Guide* (paging, IDT, protection).
   https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html
5. Wikipedia — *x86-64* (history, AMD64/Intel 64 naming, register set).
   https://en.wikipedia.org/wiki/X86-64
6. Wikipedia — *Long mode* (operating submodes, compatibility mode).
   https://en.wikipedia.org/wiki/Long_mode
7. Wikipedia — *Physical Address Extension* and *Page table* (paging structures, 4-level/5-level paging).
   https://en.wikipedia.org/wiki/Page_table
8. System V Application Binary Interface, AMD64 Architecture Processor Supplement (calling convention).
   https://gitlab.com/x86-psABIs/x86-64-ABI
9. Agner Fog, *The microarchitecture of Intel, AMD, and VIA CPUs* (pipeline stages, execution ports, out-of-order details).
   https://www.agner.org/optimize/microarchitecture.pdf
10. Wikipedia — *Advanced Vector Extensions* and *Streaming SIMD Extensions* (SIMD register history).
    https://en.wikipedia.org/wiki/Advanced_Vector_Extensions

All diagrams in this document (block diagrams, register maps, paging diagram, pipeline
diagram) were hand-drawn in ASCII/Markdown for this document based on the architectural
facts described in the sources above — they are not reproductions of any copyrighted
figures.