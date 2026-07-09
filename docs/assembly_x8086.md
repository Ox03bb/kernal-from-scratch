# Intel 8086 Instruction Set Reference Manual
*A structured, heavily indexed markdown reference for systems programmers, reverse engineers, and low-level tooling authors.*

> **Scope note:** This document covers the real Intel 8086/8088 instruction set. A few mnemonics that are commonly (and incorrectly) lumped in with "8086 assembly" — `PUSHA`, `POPA`, `BOUND`, `ENTER`, `LEAVE`, `IMUL reg,imm`, shift-by-immediate — were introduced later (80186/80286+) and are explicitly flagged as such below so you don't reach for them on real 8086/8088 silicon or an 8086-only emulator/assembler target (`.8086` directive in MASM).

---

## Table of Contents

### 1. Data Transfer Instructions
* **General Purpose:** [`MOV`](#mov) | [`PUSH`](#push) | [`POP`](#pop) | [`XCHG`](#xchg) | [`XLAT`](#xlat)
* **Address Loading:** [`LEA`](#lea) | [`LDS`](#lds) | [`LES`](#les)
* **Flag Transfer:** [`LAHF`](#lahf) | [`SAHF`](#sahf) | [`PUSHF`](#pushf) | [`POPF`](#popf)
* **I/O Port:** [`IN`](#in) | [`OUT`](#out)
* **80186+ addenda:** [`PUSHA / POPA`](#pusha--popa-80186)

### 2. Arithmetic Instructions
* **Addition:** [`ADD`](#add) | [`ADC`](#adc) | [`INC`](#inc) | [`AAA`](#aaa) | [`DAA`](#daa)
* **Subtraction:** [`SUB`](#sub) | [`SBB`](#sbb) | [`DEC`](#dec) | [`NEG`](#neg) | [`CMP`](#cmp) | [`AAS`](#aas) | [`DAS`](#das)
* **Multiplication:** [`MUL`](#mul) | [`IMUL`](#imul) | [`AAM`](#aam)
* **Division:** [`DIV`](#div) | [`IDIV`](#idiv) | [`AAD`](#aad) | [`CBW`](#cbw) | [`CWD`](#cwd)

### 3. Bit Manipulation & Logical
* **Logical:** [`AND`](#and) | [`OR`](#or) | [`XOR`](#xor) | [`NOT`](#not) | [`TEST`](#test)
* **Shifts:** [`SHL / SAL`](#shl--sal) | [`SHR`](#shr) | [`SAR`](#sar)
* **Rotates:** [`ROL`](#rol) | [`ROR`](#ror) | [`RCL`](#rcl) | [`RCR`](#rcr)

### 4. String Operations
* **Control:** [`REP / REPE / REPZ / REPNE / REPNZ`](#rep--repe--repz--repne--repnz)
* **Primitives:** [`MOVSB / MOVSW`](#movsb--movsw) | [`CMPSB / CMPSW`](#cmpsb--cmpsw) | [`SCASB / SCASW`](#scasb--scasw) | [`LODSB / LODSW`](#lodsb--lodsw) | [`STOSB / STOSW`](#stosb--stosw)

### 5. Control Flow & Branching
* **Unconditional:** [`JMP`](#jmp) | [`CALL`](#call) | [`RET / RETF`](#ret--retf)
* **Conditional Jumps:** [Full Jcc reference table](#conditional-jumps-jcc) — `JA/JNBE`, `JAE/JNB/JNC`, `JB/JNAE/JC`, `JBE/JNA`, `JG/JNLE`, `JGE/JNL`, `JL/JNGE`, `JLE/JNG`, `JE/JZ`, `JNE/JNZ`, `JO`, `JNO`, `JS`, `JNS`, `JP/JPE`, `JNP/JPO`, `JCXZ`
* **Looping:** [`LOOP`](#loop--loope--loopz--loopne--loopnz) | [`LOOPE / LOOPZ`](#loop--loope--loopz--loopne--loopnz) | [`LOOPNE / LOOPNZ`](#loop--loope--loopz--loopne--loopnz)

### 6. Processor Control & Flags
* **Flag Operators:** [`CLC`](#clc) | [`STC`](#stc) | [`CMC`](#cmc) | [`CLD`](#cld) | [`STD`](#std) | [`CLI`](#cli) | [`STI`](#sti)
* **Miscellaneous:** [`HLT`](#hlt) | [`NOP`](#nop) | [`WAIT`](#wait) | [`ESC`](#esc) | [`LOCK`](#lock) | [`INT`](#int) | [`INTO`](#into) | [`IRET`](#iret)

---

## Alphabetical Instruction Set Quick Links

| | | | | | | |
|---|---|---|---|---|---|---|
| [AAA](#aaa) | [AAD](#aad) | [AAM](#aam) | [AAS](#aas) | [ADC](#adc) | [ADD](#add) | [AND](#and) |
| [CALL](#call) | [CBW](#cbw) | [CLC](#clc) | [CLD](#cld) | [CLI](#cli) | [CMC](#cmc) | [CMP](#cmp) |
| [CMPSB](#cmpsb--cmpsw) | [CMPSW](#cmpsb--cmpsw) | [CWD](#cwd) | [DAA](#daa) | [DAS](#das) | [DEC](#dec) | [DIV](#div) |
| [ESC](#esc) | [HLT](#hlt) | [IDIV](#idiv) | [IMUL](#imul) | [IN](#in) | [INC](#inc) | [INT](#int) |
| [INTO](#into) | [IRET](#iret) | [Jcc (all conditions)](#conditional-jumps-jcc) | [JCXZ](#conditional-jumps-jcc) | [JMP](#jmp) | [LAHF](#lahf) | [LDS](#lds) |
| [LEA](#lea) | [LES](#les) | [LOCK](#lock) | [LODSB](#lodsb--lodsw) | [LODSW](#lodsb--lodsw) | [LOOP family](#loop--loope--loopz--loopne--loopnz) | [MOV](#mov) |
| [MOVSB](#movsb--movsw) | [MOVSW](#movsb--movsw) | [MUL](#mul) | [NEG](#neg) | [NOP](#nop) | [NOT](#not) | [OR](#or) |
| [OUT](#out) | [POP](#pop) | [POPF](#popf) | [PUSH](#push) | [PUSHF](#pushf) | [PUSHA / POPA (80186+)](#pusha--popa-80186) | [RCL](#rcl) |
| [RCR](#rcr) | [REP family](#rep--repe--repz--repne--repnz) | [RET / RETF](#ret--retf) | [ROL](#rol) | [ROR](#ror) | [SAHF](#sahf) | [SAR](#sar) |
| [SBB](#sbb) | [SCASB](#scasb--scasw) | [SCASW](#scasb--scasw) | [SHL/SAL](#shl--sal) | [SHR](#shr) | [STC](#stc) | [STD](#std) |
| [STI](#sti) | [STOSB](#stosb--stosw) | [STOSW](#stosb--stosw) | [SUB](#sub) | [TEST](#test) | [WAIT](#wait) | [XCHG](#xchg) |
| [XLAT](#xlat) | [XOR](#xor) | | | | | |

---

## Operand Type Key
* **REG**: General purpose register (`AX, BX, CX, DX, AH, AL, BL, BH, CH, CL, DH, DL, DI, SI, BP, SP`).
* **SREG**: Segment register (`DS, ES, SS`, and `CS` as *source only* — you cannot `MOV CS, ...`).
* **memory**: Memory reference (e.g., `[BX]`, `[BX+SI+7]`, variable names). On the 8086 the default segment is `DS` for most memory operands, `SS` for anything using `BP` as a base register, and `ES` (non-overridable) for string-instruction destinations addressed via `DI`.
* **immediate**: Constant value (e.g., `5`, `-24`, `3Fh`, `10001101b`).
* **short-label / near-label / far-label**: A code address. *Short* = 8-bit signed displacement (-128..+127 bytes from the next instruction). *Near* = 16-bit displacement, same code segment. *Far* = full new `CS:IP` pair, different segment allowed.

### Addressing Modes (effective address calculation)
The 8086 computes a memory operand's effective address from up to two registers plus a displacement:

| Mode | Effective Address | Notes |
|---|---|---|
| `[BX]`, `[BP]`, `[SI]`, `[DI]` | base or index register alone | `[BP]` defaults to `SS`, others to `DS` |
| `[BX+SI]`, `[BX+DI]`, `[BP+SI]`, `[BP+DI]` | base + index | the only legal base+index pairings |
| `[BX+disp8/16]`, `[BP+disp8/16]`, etc. | reg + displacement | displacement is sign-extended if 8-bit |
| `[BX+SI+disp]` etc. | base + index + displacement | most general form |
| `[disp16]` | direct address | no base/index register at all |

`CX`, `DX`, `AX` **cannot** be used as base/index registers for memory addressing — only `BX`, `BP`, `SI`, `DI` participate in the effective-address calculation.

### FLAGS Register Bit Layout
```
15 14 13 12 11 10 9  8  7  6  5  4  3  2  1  0
 -  -  -  -  OF DF IF TF SF ZF -  AF -  PF -  CF
```
`OF`=Overflow, `DF`=Direction, `IF`=Interrupt-enable, `TF`=Trap (single-step), `SF`=Sign, `ZF`=Zero, `AF`=Auxiliary carry (nibble), `PF`=Parity (low byte, even parity), `CF`=Carry. Bits marked `-` are undefined/reserved on the 8086.

---

## Detailed Instruction Lexicon

### AAA
* **Opcode:** `37`
* **Operands:** No operands
* **Description:** ASCII Adjust after Addition. Corrects the result in `AH` and `AL` after an addition performed on two unpacked BCD digits (one digit per byte, high nibble zero).
* **Algorithm:**
  ```text
  if (low nibble of AL > 9) or (AF = 1) then:
      AL = AL + 6
      AH = AH + 1
      AF = 1
      CF = 1
  else
      AF = 0
      CF = 0
  AL = AL AND 0Fh   ; clear high nibble of AL
  ```
* **Example:**
  ```assembly
  MOV AX, 0007h   ; represents unpacked digit 7
  ADD AL, 5       ; AL = 0Ch (12) -- invalid BCD digit
  AAA             ; AH = 01, AL = 02  -> digits "12"
  ```
* **Flags Affected:** `C:r`, `A:r`, `Z:?`, `S:?`, `O:?`, `P:?` *(r = set according to result, ? = undefined)*

---

### AAD
* **Opcode:** `D5 0A`
* **Operands:** No operands
* **Description:** ASCII Adjust before Division. Converts two unpacked BCD digits held in `AH` (tens) and `AL` (units) into a single binary byte in `AL`, so that a subsequent `DIV` operates on a normal binary value.
* **Algorithm:**
  ```text
  AL = (AH * 10) + AL
  AH = 0
  ```
* **Example:**
  ```assembly
  MOV AX, 0105h   ; AH = 01 (tens), AL = 05 (units) -> represents 15
  AAD             ; AX = 000Fh (15 decimal)
  ```
* **Flags Affected:** `Z:r`, `S:r`, `P:r`, `C:?`, `O:?`, `A:?`

---

### AAM
* **Opcode:** `D4 0A`
* **Operands:** No operands
* **Description:** ASCII Adjust after Multiplication. Splits the binary byte in `AL` (the result of multiplying two single BCD digits) back into two unpacked BCD digits.
* **Algorithm:**
  ```text
  AH = AL / 10
  AL = AL mod 10
  ```
* **Example:**
  ```assembly
  MOV AL, 15      ; AL = 0Fh (result of 3 * 5)
  AAM             ; AH = 01, AL = 05 -> digits "15"
  ```
* **Flags Affected:** `Z:r`, `S:r`, `P:r`, `C:?`, `O:?`, `A:?`

---

### AAS
* **Opcode:** `3F`
* **Operands:** No operands
* **Description:** ASCII Adjust after Subtraction. Corrects the result in `AH` and `AL` after a subtraction performed on two unpacked BCD digits.
* **Algorithm:**
  ```text
  if (low nibble of AL > 9) or (AF = 1) then:
      AL = AL - 6
      AH = AH - 1
      AF = 1
      CF = 1
  else
      AF = 0
      CF = 0
  AL = AL AND 0Fh
  ```
* **Example:**
  ```assembly
  MOV AX, 0002h   ; digit 2
  SUB AL, 5       ; AL = FDh (borrow occurred)
  AAS             ; AH = FFh (borrow propagated), AL = 07  -> represents -(?)3 with borrow chained
  ```
* **Flags Affected:** `C:r`, `A:r`, `Z:?`, `S:?`, `O:?`, `P:?`

---

### ADC
* **Opcode:** `10-15` (various `reg/rm, reg/rm/imm` forms, same encoding family as `ADD` with a different `reg` field in the ModRM byte)
* **Operands:** `REG, memory` | `memory, REG` | `REG, REG` | `memory, immediate` | `REG, immediate`
* **Description:** Add with Carry. Computes `operand1 + operand2 + CF` and stores the result in `operand1`. Used to chain addition across multi-word (e.g., 32-bit or 64-bit) values built from 16-bit registers.
* **Example:**
  ```assembly
  ; 32-bit add: DX:AX = DX:AX + CX:BX
  ADD AX, BX
  ADC DX, CX
  ```
* **Flags Affected:** `C:r`, `Z:r`, `S:r`, `O:r`, `P:r`, `A:r`

---

### ADD
* **Opcode:** `00-05` (`00`/`01` = rm,reg byte/word; `02`/`03` = reg,rm; `04`/`05` = AL/AX,imm; `80`/`81`/`83` /0 for rm,imm)
* **Operands:** `REG, memory` | `memory, REG` | `REG, REG` | `memory, immediate` | `REG, immediate`
* **Description:** Add. Computes `operand1 + operand2` and stores the result in `operand1`.
* **Example:**
  ```assembly
  MOV AL, 5   ; AL = 5
  ADD AL, -3  ; AL = 2
  ```
* **Flags Affected:** `C:r`, `Z:r`, `S:r`, `O:r`, `P:r`, `A:r`

---

### AND
* **Opcode:** `20-25`, `80`/`81`/`83` `/4`
* **Operands:** `REG, memory` | `memory, REG` | `REG, REG` | `memory, immediate` | `REG, immediate`
* **Description:** Bitwise Logical AND between two operands; result replaces `operand1`. Commonly used to mask off bits (`AND AL, 0Fh` isolates the low nibble). Always clears `OF` and `CF` since bitwise ops have no meaningful carry/overflow.
* **Example:**
  ```assembly
  MOV AL, 10110110b
  AND AL, 00001111b   ; AL = 00000110b -- isolates low nibble
  ```
* **Flags Affected:** `C:0`, `O:0`, `Z:r`, `S:r`, `P:r`, `A:?`

---

### CALL
* **Opcode:** `E8` (near, relative disp16) | `9A` (far, direct seg:offset) | `FF /2` (near indirect) | `FF /3` (far indirect)
* **Operands:** `near-label` | `far-label` | `REG` | `memory` (indirect)
* **Description:** Calls a procedure. A **near call** pushes the return `IP` (2 bytes) and jumps within the same code segment. A **far call** pushes `CS` then `IP` (4 bytes total) and loads a new `CS:IP`, allowing calls across segments.
* **Example:**
  ```assembly
  CALL PrintString      ; near call, label in same segment

  PrintString:
      ; ... procedure body ...
      RET
  ```
* **Flags Affected:** Unchanged

---

### CBW
* **Opcode:** `98`
* **Operands:** No operands
* **Description:** Convert Byte to Word. Sign-extends `AL` into `AH`, producing a correctly signed 16-bit value in `AX`. Typically used before a signed 16-bit operation (e.g., before `IDIV` with a 16-bit divisor).
* **Algorithm:**
  ```text
  if high bit of AL = 1 then AH = 0FFh else AH = 0
  ```
* **Example:**
  ```assembly
  MOV AL, -5   ; AL = 0FBh
  CBW          ; AX = 0FFFBh (-5 as a word)
  ```
* **Flags Affected:** Unchanged

---

### CLC
* **Opcode:** `F8`
* **Operands:** No operands
* **Description:** Clear Carry Flag (`CF = 0`).
* **Flags Affected:** `C:0`

---

### CLD
* **Opcode:** `FC`
* **Operands:** No operands
* **Description:** Clear Direction Flag (`DF = 0`). String instructions (`MOVSx`, `CMPSx`, `SCASx`, `LODSx`, `STOSx`) will auto-**increment** `SI`/`DI` after each iteration while `DF = 0`.
* **Flags Affected:** `D:0`

---

### CLI
* **Opcode:** `FA`
* **Operands:** No operands
* **Description:** Clear Interrupt Enable Flag (`IF = 0`). Disables maskable hardware interrupts (does **not** affect NMI). Commonly paired with `STI` to bracket a critical section.
* **Flags Affected:** `I:0`

---

### CMC
* **Opcode:** `F5`
* **Operands:** No operands
* **Description:** Complement Carry Flag. Toggles the current `CF` value (1→0 or 0→1).
* **Flags Affected:** `C:r`

---

### CMP
* **Opcode:** `38-3D`, `80`/`81`/`83` `/7`
* **Operands:** `REG, memory` | `memory, REG` | `REG, REG` | `memory, immediate` | `REG, immediate`
* **Description:** Compare operands. Internally computes `operand1 - operand2` and sets flags accordingly, but discards the result — neither operand is modified. Almost always followed by a conditional jump (`JE`, `JG`, `JB`, ...).
* **Example:**
  ```assembly
  MOV AX, 10
  CMP AX, 20   ; flags set as if AX - 20 were computed; AX unchanged
  JL  Less     ; taken, since 10 < 20 (signed compare)
  ```
* **Flags Affected:** `C:r`, `Z:r`, `S:r`, `O:r`, `P:r`, `A:r`

---

### CMPSB / CMPSW
* **Opcode:** `A6` (byte) | `A7` (word)
* **Operands:** No operands (implicit `DS:[SI]` vs `ES:[DI]`)
* **Description:** Compare String Byte/Word. Subtracts the byte/word at `ES:[DI]` from the one at `DS:[SI]`, sets flags exactly like `CMP`, then advances both `SI` and `DI` by 1 (byte) or 2 (word) — incrementing if `DF=0`, decrementing if `DF=1`. Usually prefixed with `REPE`/`REPNE` to scan for the first mismatch/match between two buffers.
* **Example:**
  ```assembly
  CLD
  MOV CX, 10
  MOV SI, OFFSET Buf1
  MOV DI, OFFSET Buf2
  REPE CMPSB       ; advance while bytes are equal and CX <> 0
  JE   Identical   ; CX reached 0 with all bytes equal
  ```
* **Flags Affected:** `C:r`, `Z:r`, `S:r`, `O:r`, `P:r`, `A:r`

---

### CWD
* **Opcode:** `99`
* **Operands:** No operands
* **Description:** Convert Word to Double Word. Sign-extends `AX` into `DX`, producing a signed 32-bit value in `DX:AX`. Used before a signed 32-bit-by-16-bit `IDIV`.
* **Algorithm:**
  ```text
  if high bit of AX = 1 then DX = FFFFh else DX = 0000h
  ```
* **Example:**
  ```assembly
  MOV AX, -8      ; AX = FFF8h
  CWD             ; DX:AX = FFFF:FFF8h  (-8 as a doubleword)
  ```
* **Flags Affected:** Unchanged

---

### DAA
* **Opcode:** `27`
* **Operands:** No operands
* **Description:** Decimal Adjust after Addition. Adjusts the packed BCD byte in `AL` (two BCD digits per byte) after an `ADD`/`ADC` so it holds a valid packed BCD result.
* **Algorithm:**
  ```text
  old_AL = AL; old_CF = CF
  if (low nibble of AL > 9) or (AF = 1) then
      AL = AL + 6; AF = 1
  if (old_AL > 99h) or (old_CF = 1) or (AL > 9Fh after above) then
      AL = AL + 60h; CF = 1
  ```
* **Example:**
  ```assembly
  MOV AL, 0x28   ; packed BCD 28
  MOV BL, 0x14   ; packed BCD 14
  ADD AL, BL     ; AL = 0x3C (binary sum, not valid BCD)
  DAA            ; AL = 0x42  -> correct packed BCD for 28+14=42
  ```
* **Flags Affected:** `C:r`, `A:r`, `Z:r`, `S:r`, `P:r`, `O:?`

---

### DAS
* **Opcode:** `2F`
* **Operands:** No operands
* **Description:** Decimal Adjust after Subtraction. Corrects the packed BCD byte in `AL` after a `SUB`/`SBB`, mirroring `DAA`'s logic but subtracting `6`/`60h` instead of adding.
* **Flags Affected:** `C:r`, `A:r`, `Z:r`, `S:r`, `P:r`, `O:?`

---

### DEC
* **Opcode:** `48-4F` (reg, 1-byte form) | `FE /1` (byte rm) | `FF /1` (word rm)
* **Operands:** `REG` | `memory`
* **Description:** Decrement operand by 1. **Does not affect `CF`** — this is the key difference from `SUB reg, 1`, which lets `DEC`/`INC` be used inside a loop counter without disturbing a carry chain being tracked separately.
* **Example:**
  ```assembly
  MOV CX, 5
  Top:
      ; ... loop body ...
      DEC CX
      JNZ Top
  ```
* **Flags Affected:** `Z:r`, `S:r`, `O:r`, `P:r`, `A:r` *(CF unchanged)*

---

### DIV
* **Opcode:** `F6 /6` (byte) | `F7 /6` (word)
* **Operands:** `REG` | `memory`
* **Description:** Unsigned division.
  * 8-bit divisor: `AX / operand` → Quotient in `AL`, Remainder in `AH`.
  * 16-bit divisor: `DX:AX / operand` → Quotient in `AX`, Remainder in `DX`.
  * Divide overflow (quotient too large to fit, or divide-by-zero) triggers `INT 0`, not a flag update.
* **Example:**
  ```assembly
  MOV DX, 0        ; high word of dividend = 0
  MOV AX, 17       ; low word of dividend = 17
  MOV BX, 5
  DIV BX           ; AX = 3 (quotient), DX = 2 (remainder)
  ```
* **Flags Affected:** All flags undefined.

---

### ESC
* **Opcode:** `D8-DF`
* **Operands:** `immediate, memory/REG`
* **Description:** Escape. Reserved to pass an instruction and an operand through to a coprocessor (e.g., the 8087 FPU) listening on the bus; the 8086 itself fetches the memory operand (if any) but otherwise treats the opcode as a no-op. Assemblers that support the 8087 emit `ESC` encodings automatically for FPU mnemonics (`FADD`, `FMUL`, ...) rather than requiring you to write `ESC` by hand.
* **Flags Affected:** Unchanged

---

### HLT
* **Opcode:** `F4`
* **Operands:** No operands
* **Description:** Halt. Suspends instruction execution and puts the CPU into a wait state until a hardware interrupt (`NMI`, or a maskable interrupt if `IF=1`) or reset occurs. Commonly used as the tail of an OS's idle loop.

---

### IDIV
* **Opcode:** `F6 /7` (byte) | `F7 /7` (word)
* **Operands:** `REG` | `memory`
* **Description:** Signed division. Follows the same register routing as `DIV` (`AX/op → AL,AH`; `DX:AX/op → AX,DX`), but treats both dividend and divisor as two's-complement signed values, and the remainder takes the sign of the dividend. Remember to sign-extend the dividend first with `CBW`/`CWD`.
* **Example:**
  ```assembly
  MOV AX, -17
  CWD            ; sign-extend AX into DX:AX
  MOV BX, 5
  IDIV BX        ; AX = -3 (quotient), DX = -2 (remainder)
  ```
* **Flags Affected:** All flags undefined.

---

### IMUL
* **Opcode:** `F6 /5` (byte) | `F7 /5` (word)
* **Operands:** `REG` | `memory`
* **Description:** Signed multiplication.
  * 8-bit source: `AL * operand` → result in `AX`.
  * 16-bit source: `AX * operand` → result in `DX:AX`.
  * `CF` and `OF` are set if the upper half of the result is *not* simply the sign-extension of the lower half (i.e., the "full" result needed more than the lower half to represent it); cleared otherwise.
* **Example:**
  ```assembly
  MOV AL, -4
  MOV BL, 5
  IMUL BL        ; AX = -20 (0FFECh); CF=OF=0 since -20 fits in AL sign-extended
  ```
* **Note:** The two/three-operand immediate forms (`IMUL reg, rm, imm`) are **80186+ only** — on true 8086 you only have the single-operand form above.
* **Flags Affected:** `C:r`, `O:r`; `Z`,`S`,`P`,`A` undefined.

---

### IN
* **Opcode:** `E4`/`E5` (fixed 8-bit port) | `EC`/`ED` (port in `DX`)
* **Operands:** `AL, immedByte` | `AX, immedByte` | `AL, DX` | `AX, DX`
* **Description:** Input from Port. Reads a byte (`AL`) or word (`AX`) from the I/O address space. The immediate form only reaches ports `0-255`; use the `DX` form to address the full 16-bit port space (0-65535).
* **Example:**
  ```assembly
  MOV DX, 60h   ; e.g., keyboard controller data port
  IN  AL, DX
  ```
* **Flags Affected:** Unchanged

---

### INC
* **Opcode:** `40-47` (reg, 1-byte form) | `FE /0` (byte rm) | `FF /0` (word rm)
* **Operands:** `REG` | `memory`
* **Description:** Increment operand by 1. Like `DEC`, does **not** affect `CF`.
* **Flags Affected:** `Z:r`, `S:r`, `O:r`, `P:r`, `A:r` *(CF unchanged)*

---

### INT
* **Opcode:** `CD imm8` (`CC` is the dedicated 1-byte `INT 3` breakpoint encoding)
* **Operands:** `immediate` (interrupt vector number, 0-255)
* **Description:** Software Interrupt. Pushes `FLAGS`, then `CS`, then `IP`; clears `IF` and `TF`; then loads `CS:IP` from the 4-byte vector-table entry at physical address `vector * 4`. Used for BIOS/DOS services (e.g., `INT 21h`) and debugging (`INT 3`).
* **Example:**
  ```assembly
  MOV AH, 4Ch    ; DOS "terminate process" function
  INT 21h
  ```
* **Flags Affected:** `I:0`, `T:0` (all others pushed to stack, unchanged in register)

---

### INTO
* **Opcode:** `CE`
* **Operands:** No operands
* **Description:** Interrupt on Overflow. Executes `INT 4` if and only if `OF = 1`; otherwise it's a no-op. A cheap way to add overflow checking after signed arithmetic without a conditional branch.
* **Flags Affected:** Unchanged (unless taken, then as `INT`)

---

### IRET
* **Opcode:** `CF`
* **Operands:** No operands
* **Description:** Interrupt Return. Pops `IP`, then `CS`, then `FLAGS` (the reverse order of what `INT`/hardware interrupt entry pushed), fully restoring pre-interrupt execution state including all flags.
* **Flags Affected:** All flags restored from stack

---

### JMP
* **Opcode:** `EB` (short, disp8) | `E9` (near, disp16) | `EA` (far, direct) | `FF /4` (near indirect) | `FF /5` (far indirect)
* **Operands:** `short-label` | `near-label` | `far-label` | `REG` (near indirect) | `memory` (indirect, near or far depending on operand size)
* **Description:** Unconditional jump to the target. A **short** jump is the most compact form (2 bytes total) but only reaches ±127 bytes; assemblers pick it automatically when the target is close enough unless you force `JMP NEAR PTR`/`JMP FAR PTR`.
* **Example:**
  ```assembly
  JMP SHORT SkipData
  DB  "unreachable data", 0
  SkipData:
      NOP
  ```
* **Flags Affected:** Unchanged

---

### LAHF
* **Opcode:** `9F`
* **Operands:** No operands
* **Description:** Load AH from Flags. Copies the low byte of the flags register (`SF, ZF, AF, PF, CF`) into `AH`, in the bit layout: `SF ZF ? AF ? PF ? CF`. Predates `PUSHF`; historically used to save/restore flags cheaply, and required by `SAHF`-based old floating point emulation code.
* **Example:**
  ```assembly
  STC
  LAHF        ; AH now has CF bit (bit 0) = 1
  ```
* **Flags Affected:** Unchanged (reads flags, doesn't modify them)

---

### SAHF
* **Opcode:** `9E`
* **Operands:** No operands
* **Description:** Store AH into Flags. The inverse of `LAHF` — copies `AH`'s bits back into `SF, ZF, AF, PF, CF`. `OF`, `DF`, `IF`, `TF` are untouched.
* **Flags Affected:** `S:r`, `Z:r`, `A:r`, `P:r`, `C:r` (loaded from `AH`)

---

### LDS
* **Opcode:** `C5 /r`
* **Operands:** `REG, memory` (memory must be a 32-bit far pointer: offset word followed by segment word)
* **Description:** Load pointer using `DS`. Loads the 16-bit offset from `memory` into `REG`, and the following 16-bit segment value into `DS`. Used to load a far pointer (e.g., a string address passed on the stack) in one instruction.
* **Example:**
  ```assembly
  ; FarPtr is a 4-byte label: DW offset, DW segment
  LDS SI, FarPtr    ; SI = offset word, DS = segment word
  MOV AL, [SI]      ; dereference through the freshly loaded DS:SI
  ```
* **Flags Affected:** Unchanged

---

### LES
* **Opcode:** `C4 /r`
* **Operands:** `REG, memory` (same 32-bit far-pointer layout as `LDS`)
* **Description:** Load pointer using `ES`. Identical to `LDS` except the segment half is loaded into `ES` instead of `DS`. Frequently paired with string instructions, since `ES:DI` is the fixed destination pair for `MOVSx`/`STOSx`/`SCASx`.
* **Example:**
  ```assembly
  LES DI, FarPtr    ; DI = offset word, ES = segment word
  STOSB             ; store AL at ES:DI
  ```
* **Flags Affected:** Unchanged

---

### LEA
* **Opcode:** `8D /r`
* **Operands:** `REG, memory`
* **Description:** Load Effective Address. Computes the *offset* of a memory operand (applying the addressing-mode arithmetic, but never dereferencing it) and stores that offset in the destination register. Unlike `MOV REG, OFFSET label` (a compile-time constant), `LEA` can compute addresses that depend on runtime register values.
* **Example:**
  ```assembly
  MOV BX, 100
  LEA AX, [BX+4]    ; AX = 104 (no memory access occurs)
  ```
* **Flags Affected:** Unchanged

---

### LODSB / LODSW
* **Opcode:** `AC` (byte) | `AD` (word)
* **Operands:** No operands (implicit `DS:[SI]` → `AL`/`AX`)
* **Description:** Load String Byte/Word. Copies the byte/word at `DS:[SI]` into `AL`/`AX`, then advances `SI` by 1/2 according to `DF`. Rarely used with a `REP` prefix (since the accumulator would just be overwritten each iteration) — usually appears in a manual loop alongside other per-element processing.
* **Example:**
  ```assembly
  CLD
  MOV SI, OFFSET MyString
  MOV CX, StrLen
  NextChar:
      LODSB
      ; ... process character in AL ...
      LOOP NextChar
  ```
* **Flags Affected:** Unchanged

---

### MOV
* **Opcode:** `88-8C`, `8E`, `A0-A3`, `B0-BF`, `C6`/`C7`
* **Operands:** `REG, memory` | `memory, REG` | `REG, REG` | `memory, immediate` | `REG, immediate` | `SREG, memory` | `memory, SREG` | `REG, SREG` | `SREG, REG`
* **Description:** Move. Copies data from source to destination operand; source is unaffected. **Illegal combinations:** memory-to-memory, segment-to-segment, and immediate-to-segment-register are all disallowed directly — route through a general register instead (e.g., `MOV AX, imm` then `MOV DS, AX`).
* **Example:**
  ```assembly
  MOV AX, 1234h
  MOV DS, AX        ; cannot MOV DS, 1234h directly
  MOV [SI], AL
  ```
* **Flags Affected:** Unchanged

---

### MOVSB / MOVSW
* **Opcode:** `A4` (byte) | `A5` (word)
* **Operands:** No operands (implicit `DS:[SI]` → `ES:[DI]`)
* **Description:** Move String Byte/Word. Copies the byte/word at `DS:[SI]` to `ES:[DI]`, then advances both `SI` and `DI` by 1/2 according to `DF`. The classic block-copy primitive; almost always paired with a `REP` prefix.
* **Example:**
  ```assembly
  CLD
  MOV SI, OFFSET Src
  MOV DI, OFFSET Dst
  MOV CX, 256
  REP MOVSB          ; copy 256 bytes from Src to Dst
  ```
* **Flags Affected:** Unchanged

---

### MUL
* **Opcode:** `F6 /4` (byte) | `F7 /4` (word)
* **Operands:** `REG` | `memory`
* **Description:** Unsigned multiplication.
  * 8-bit source: `AL * operand` → result in `AX`. `CF`/`OF` set if `AH != 0`.
  * 16-bit source: `AX * operand` → result in `DX:AX`. `CF`/`OF` set if `DX != 0`.
* **Example:**
  ```assembly
  MOV AL, 200
  MOV BL, 3
  MUL BL           ; AX = 600 (0258h); CF=OF=1 since AH != 0
  ```
* **Flags Affected:** `C:r`, `O:r`; `Z`,`S`,`P`,`A` undefined.

---

### NEG
* **Opcode:** `F6 /3` (byte) | `F7 /3` (word)
* **Operands:** `REG` | `memory`
* **Description:** Two's Complement Negation. Computes `0 - operand` (inverts all bits, adds 1) in place. `CF` is set to 1 unless the operand was 0 (negating 0 leaves 0, with `CF=0`).
* **Example:**
  ```assembly
  MOV AL, 5
  NEG AL      ; AL = 0FBh (-5); CF = 1
  ```
* **Flags Affected:** `C:r`, `Z:r`, `S:r`, `O:r`, `P:r`, `A:r`

---

### NOP
* **Opcode:** `90`
* **Operands:** No operands
* **Description:** No Operation. Consumes 3 clock cycles and changes nothing; internally identical to `XCHG AX, AX` (which is in fact the encoding `90` decodes as).

---

### NOT
* **Opcode:** `F6 /2` (byte) | `F7 /2` (word)
* **Operands:** `REG` | `memory`
* **Description:** One's Complement Bitwise Inversion — flips every bit of the operand. Unlike `NEG`, this never touches any flag.
* **Flags Affected:** Unchanged

---

### OR
* **Opcode:** `08-0D`, `80`/`81`/`83` `/1`
* **Operands:** `REG, memory` | `memory, REG` | `REG, REG` | `memory, immediate` | `REG, immediate`
* **Description:** Bitwise Logical Inclusive OR; result replaces `operand1`. Commonly used to force specific bits on (`OR AL, 20h` sets bit 5).
* **Flags Affected:** `C:0`, `O:0`, `Z:r`, `S:r`, `P:r`, `A:?`

---

### OUT
* **Opcode:** `E6`/`E7` (fixed 8-bit port) | `EE`/`EF` (port in `DX`)
* **Operands:** `immedByte, AL` | `immedByte, AX` | `DX, AL` | `DX, AX`
* **Description:** Output to Port. Writes a byte (`AL`) or word (`AX`) to the given I/O address. Mirrors `IN`'s two addressing forms.
* **Example:**
  ```assembly
  MOV DX, 378h  ; e.g., a parallel port data register
  MOV AL, 0FFh
  OUT DX, AL
  ```
* **Flags Affected:** Unchanged

---

### POP
* **Opcode:** `58-5F` (reg) | `8F /0` (memory) | `07`/`17`/`1F` (`ES`/`SS`/`DS`; note `POP CS` is not a legal encoding)
* **Operands:** `REG` | `memory` | `SREG` (`ES`, `SS`, `DS` only)
* **Description:** Pops the word at the top of the stack (`SS:[SP]`) into the operand, then increments `SP` by 2.
* **Example:**
  ```assembly
  PUSH AX
  ; ... AX is now free to reuse ...
  POP  AX     ; restore original AX
  ```
* **Flags Affected:** Unchanged

---

### POPF
* **Opcode:** `9D`
* **Operands:** No operands
* **Description:** Pop Flags. Pops the top-of-stack word directly into the `FLAGS` register, restoring every flag bit (including `IF`, `DF`, `TF`) in one shot. `SP` increments by 2.
* **Flags Affected:** All flags restored from stack

---

### PUSH
* **Opcode:** `50-57` (reg) | `FF /6` (memory) | `06`/`0E`/`16`/`1E` (`ES`/`CS`/`SS`/`DS`)
* **Operands:** `REG` | `memory` | `SREG`
* **Description:** Decrements `SP` by 2, then stores the operand word at `SS:[SP]`.
* **Example:**
  ```assembly
  PUSH BX
  PUSH CX
  ; ... use BX/CX as scratch ...
  POP  CX
  POP  BX     ; restore in reverse order
  ```
* **Flags Affected:** Unchanged

---

### PUSHF
* **Opcode:** `9C`
* **Operands:** No operands
* **Description:** Push Flags. Decrements `SP` by 2, then stores the entire `FLAGS` register at `SS:[SP]`. Paired with `POPF` to save/restore complete processor state, or with a manual pop into a register to inspect flags directly.
* **Flags Affected:** Unchanged

---

### PUSHA / POPA *(80186+)*
* **Opcode:** `60` (`PUSHA`) | `61` (`POPA`)
* **Operands:** No operands
* **Description:** ⚠️ **Not available on the real 8086/8088.** These were introduced with the 80186/80286. `PUSHA` pushes `AX, CX, DX, BX, SP(original), BP, SI, DI` in that order; `POPA` reverses it (restoring `SP`'s original *value*, not popping into `SP`). Included here only because they're frequently — and incorrectly — assumed to be part of the base 8086 set; if you're targeting real 8086/8088 hardware or an assembler in `.8086` mode, push/pop the registers you need individually instead.
* **Flags Affected:** Unchanged

---

### RCL / RCR
* **Opcode:** `D0`/`D1` `/2` (`RCL`, by 1) | `D2`/`D3` `/2` (`RCL`, by `CL`) | `D0`/`D1` `/3` (`RCR`, by 1) | `D2`/`D3` `/3` (`RCR`, by `CL`)
* **Operands:** `REG, 1` | `memory, 1` | `REG, CL` | `memory, CL`
* **Description:** Rotate through Carry Left/Right. Like `ROL`/`ROR`, but the rotation includes `CF` as an extra bit in the circle: `RCL` shifts every bit left, the old `CF` enters at the LSB, and the bit shifted out of the MSB becomes the new `CF`. `RCR` is the mirror image, shifting right. Useful for rotating a carry bit through a multi-word value (e.g., a 32-bit rotate built from two 16-bit registers).
* **Example:**
  ```assembly
  ; 32-bit left rotate of DX:AX by 1 bit
  SHL AX, 1     ; MSB of AX -> CF
  RCL DX, 1     ; CF -> LSB of DX, MSB of DX -> CF
  RCL AX, 1     ; wait -- see note below
  ```
  *(A correct 32-bit rotate needs the final carry fed back into AX's LSB; the snippet above shows the RCL/RCR mechanics — chain `SHL`/`RCL` pairs and manually re-inject the last `CF` into bit 0 of `AX` if you need a true circular 32-bit rotate.)*
* **Flags Affected:** `C:r` (last bit rotated out); `O:r` on single-bit rotates only (undefined for count > 1); `Z, S, P, A` unaffected.

---

### REP / REPE / REPZ / REPNE / REPNZ
* **Opcode:** `F3` (`REP`/`REPE`/`REPZ`) | `F2` (`REPNE`/`REPNZ`) — these are instruction *prefixes*, prepended to a string primitive's opcode byte.
* **Operands:** String primitive instruction (`MOVSB/W`, `CMPSB/W`, `SCASB/W`, `LODSB/W`, `STOSB/W`)
* **Description:** Repeats the chained string instruction while `CX != 0` (decrementing `CX` each iteration), and — for the compare/scan primitives only — also while the zero-flag condition holds: `REPE`/`REPZ` continues **while equal**, `REPNE`/`REPNZ` continues **while not equal**. Plain `REP` (used with `MOVSx`/`STOSx`, which don't set flags meaningfully for this purpose) only checks `CX`.
* **Example:**
  ```assembly
  CLD
  MOV DI, OFFSET Buf
  MOV CX, 100
  MOV AL, 0
  REP STOSB        ; zero-fill 100 bytes starting at ES:DI
  ```
* **Flags Affected:** Unchanged (the prefix itself sets no flags; the underlying primitive might)

---

### RET / RETF
* **Opcode:** `C3` (near, no cleanup) | `C2 imm16` (near, pop `imm16` extra bytes off the stack) | `CB` (far) | `CA imm16` (far, with stack cleanup)
* **Operands:** Optional `immediate` (number of extra bytes to discard from the stack after the return address — used to clean up caller-pushed arguments in a Pascal/stdcall-style calling convention)
* **Description:** Return from procedure. `RET` pops `IP` (near return, matching a near `CALL`); `RETF` additionally pops `CS` (matching a far `CALL`). The immediate-operand forms add `SP = SP + imm16` after popping the return address, discarding stack-passed arguments in one step.
* **Example:**
  ```assembly
  MyProc PROC
      PUSH BP
      MOV  BP, SP
      ; ... body, 2 words of arguments pushed by caller ...
      POP  BP
      RET  4          ; near return, discard 4 bytes of arguments
  MyProc ENDP
  ```
* **Flags Affected:** Unchanged

---

### SHL / SAL
* **Opcode:** `D0`/`D1` `/4` (by 1) | `D2`/`D3` `/4` (by `CL`)
* **Operands:** `REG, 1` | `memory, 1` | `REG, CL` | `memory, CL`
* **Description:** Shift Left / Shift Arithmetic Left (identical operation, two mnemonics for the same opcode). Each bit moves one position left; the vacated LSB is filled with `0`; the bit shifted out of the MSB is captured in `CF`. Equivalent to an unsigned multiply by 2 per shift (as long as no significant bit is lost).
* **Note:** On real 8086/8088, the shift count must be `1` or come from `CL` — `SHL reg, imm8` (immediate counts other than 1) is an **80186+** addition.
* **Example:**
  ```assembly
  MOV AL, 00000101b   ; 5
  SHL AL, 1            ; AL = 00001010b (10); CF = 0
  ```
* **Flags Affected:** `C:r` (last bit shifted out); `O:r` (valid only for single-bit shifts: set if the sign bit changed); `Z, S, P` reflect the result; `A:?`

---

### SHR
* **Opcode:** `D0`/`D1` `/5` (by 1) | `D2`/`D3` `/5` (by `CL`)
* **Operands:** Same as `SHL`
* **Description:** Logical Shift Right. Each bit moves one position right; the vacated MSB is filled with `0` (regardless of sign); the bit shifted out of the LSB goes to `CF`. Equivalent to an unsigned divide by 2 per shift.
* **Example:**
  ```assembly
  MOV AL, 10000000b    ; 128
  SHR AL, 1             ; AL = 01000000b (64); CF = 0
  ```
* **Flags Affected:** `C:r`, `O:r` (single-bit form: set if MSB changed), `Z, S, P` reflect result; `A:?`

---

### SAR
* **Opcode:** `D0`/`D1` `/7` (by 1) | `D2`/`D3` `/7` (by `CL`)
* **Operands:** Same as `SHL`
* **Description:** Arithmetic Shift Right. Identical to `SHR` except the vacated MSB positions are filled by copies of the **original sign bit** rather than `0`, preserving the operand's sign — equivalent to a signed divide by 2 per shift (rounding toward negative infinity).
* **Example:**
  ```assembly
  MOV AL, 11111000b   ; -8
  SAR AL, 1            ; AL = 11111100b (-4); sign preserved
  ```
* **Flags Affected:** `C:r` (last bit shifted out), `O:r` (single-bit form: always 0, since sign can't change), `Z, S, P` reflect result; `A:?`

---

### ROL / ROR
* **Opcode:** `D0`/`D1` `/0` (`ROL`, by 1) | `D2`/`D3` `/0` (`ROL`, by `CL`) | `D0`/`D1` `/1` (`ROR`, by 1) | `D2`/`D3` `/1` (`ROR`, by `CL`)
* **Operands:** Same as `SHL`
* **Description:** Rotate Left / Rotate Right (no carry involvement — contrast with `RCL`/`RCR`). Bits shifted off one end wrap directly to the opposite end; the last bit rotated out is also copied into `CF`.
* **Example:**
  ```assembly
  MOV AL, 10000001b
  ROL AL, 1           ; AL = 00000011b; CF = 1 (bit that wrapped around)
  ```
* **Flags Affected:** `C:r` (bit rotated out); `O:r` (single-bit form only: set if the MSB changed as a result); `Z, S, P, A` unaffected.

---

### SCASB / SCASW
* **Opcode:** `AE` (byte) | `AF` (word)
* **Operands:** No operands (implicit `AL`/`AX` vs `ES:[DI]`)
* **Description:** Scan String Byte/Word. Subtracts the byte/word at `ES:[DI]` from `AL`/`AX`, sets flags like `CMP`, then advances `DI` by 1/2 per `DF`. Typically prefixed with `REPNE` to search a buffer for a matching byte (e.g., finding a NUL terminator), or `REPE` to find the first byte that *doesn't* match.
* **Example:**
  ```assembly
  CLD
  MOV DI, OFFSET Str
  MOV AL, 0            ; looking for NUL terminator
  MOV CX, 0FFFFh
  REPNE SCASB
  ; DI now points 1 past the terminator (or CX=0 if not found)
  ```
* **Flags Affected:** `C:r`, `Z:r`, `S:r`, `O:r`, `P:r`, `A:r`

---

### STC
* **Opcode:** `F9`
* **Operands:** No operands
* **Description:** Set Carry Flag (`CF = 1`).
* **Flags Affected:** `C:1`

---

### STD
* **Opcode:** `FD`
* **Operands:** No operands
* **Description:** Set Direction Flag (`DF = 1`). String instructions will auto-**decrement** `SI`/`DI` while this is set — used when processing a buffer from high address to low (e.g., overlapping-copy scenarios where the destination is ahead of the source).
* **Flags Affected:** `D:1`

---

### STI
* **Opcode:** `FB`
* **Operands:** No operands
* **Description:** Set Interrupt Enable Flag (`IF = 1`), re-enabling maskable hardware interrupts. Note the real 8086 delays recognizing interrupts until *after* the instruction immediately following `STI` — this guarantees `STI` followed by a stack-adjusting instruction (e.g., before `IRET`) executes atomically as a pair.
* **Flags Affected:** `I:1`

---

### STOSB / STOSW
* **Opcode:** `AA` (byte) | `AB` (word)
* **Operands:** No operands (implicit `AL`/`AX` → `ES:[DI]`)
* **Description:** Store String Byte/Word. Writes `AL`/`AX` to `ES:[DI]`, then advances `DI` by 1/2 per `DF`. Paired with `REP` it's the standard "fill memory with a value" primitive (fast `memset`).
* **Example:**
  ```assembly
  CLD
  MOV DI, OFFSET Buf
  MOV CX, 512
  MOV AL, 20h          ; fill with spaces
  REP STOSB
  ```
* **Flags Affected:** Unchanged

---

### SUB
* **Opcode:** `28-2D`, `80`/`81`/`83` `/5`
* **Operands:** `REG, memory` | `memory, REG` | `REG, REG` | `memory, immediate` | `REG, immediate`
* **Description:** Subtract. Computes `operand1 - operand2` and stores the result in `operand1`.
* **Example:**
  ```assembly
  MOV AX, 10
  SUB AX, 3     ; AX = 7
  ```
* **Flags Affected:** `C:r`, `Z:r`, `S:r`, `O:r`, `P:r`, `A:r`

---

### SBB
* **Opcode:** `18-1D`, `80`/`81`/`83` `/3`
* **Operands:** `REG, memory` | `memory, REG` | `REG, REG` | `memory, immediate` | `REG, immediate`
* **Description:** Subtract with Borrow. Computes `operand1 - operand2 - CF` and stores the result in `operand1`. The subtraction counterpart to `ADC`, used to chain multi-word subtraction.
* **Example:**
  ```assembly
  ; 32-bit subtract: DX:AX = DX:AX - CX:BX
  SUB AX, BX
  SBB DX, CX
  ```
* **Flags Affected:** `C:r`, `Z:r`, `S:r`, `O:r`, `P:r`, `A:r`

---

### TEST
* **Opcode:** `84`/`85` (rm, reg) | `A8`/`A9` (`AL`/`AX`, imm) | `F6`/`F7` `/0` (rm, imm)
* **Operands:** `REG, memory` | `memory, REG` | `REG, REG` | `memory, immediate` | `REG, immediate`
* **Description:** Logical test via bitwise AND — identical computation to `AND`, but the result is discarded and only flags are updated (like `CMP` is to `SUB`). Commonly used to check individual bits (`TEST AL, 01h` then `JNZ`) without disturbing the tested register.
* **Example:**
  ```assembly
  MOV AL, 00000101b
  TEST AL, 00000001b   ; sets ZF=0 (bit 0 is set); AL unchanged
  JNZ  BitIsSet
  ```
* **Flags Affected:** `C:0`, `O:0`, `Z:r`, `S:r`, `P:r`, `A:?`

---

### WAIT
* **Opcode:** `9B`
* **Operands:** No operands
* **Description:** Wait. Suspends the CPU until the `TEST` pin is asserted (historically pulled low by an 8087 FPU signaling it has finished an operation). Used to synchronize the main CPU with a coprocessor before touching shared results — e.g., inserted automatically by assemblers before any instruction that reads memory the 8087 just wrote.
* **Flags Affected:** Unchanged

---

### LOCK
* **Opcode:** `F0` (prefix)
* **Operands:** Prefix applied to the next instruction
* **Description:** Asserts the CPU's `LOCK#` bus signal for the duration of the following instruction, preventing another bus master (e.g., another CPU, or a DMA controller) from acquiring the bus in between the read and write halves of a read-modify-write operation. Essential for implementing atomic primitives (spinlocks, semaphores) in a multiprocessor 8086 system.
* **Example:**
  ```assembly
  LOCK INC WORD PTR [SemaphoreCount]   ; atomic increment
  ```
* **Flags Affected:** Unchanged (flags depend on the locked instruction itself)

---

### XCHG
* **Opcode:** `86`/`87` (rm,reg) | `90-97` (`AX`, reg — the `90` encoding with `AX,AX` doubles as `NOP`)
* **Operands:** `REG, memory` | `memory, REG` | `REG, REG`
* **Description:** Exchange. Swaps the contents of the two operands. When one operand is memory, the exchange is automatically performed as an atomic bus-locked cycle (no explicit `LOCK` prefix needed) — a common trick for implementing a spinlock's "test-and-set."
* **Example:**
  ```assembly
  ; simple spinlock acquire
  MOV AL, 1
  Spin:
      XCHG AL, [Lock]   ; atomically swap; AL now holds the previous lock state
      TEST AL, AL
      JNZ  Spin         ; was already locked -> retry
  ```
* **Flags Affected:** Unchanged

---

### XLAT
* **Opcode:** `D7`
* **Operands:** No operands (implicit table base `DS:[BX]`, index `AL`)
* **Description:** Translate. Replaces `AL` with the byte found at `DS:[BX + AL]` — i.e., `AL` is used as an unsigned index into a 256-entry lookup table pointed to by `BX`. Classic use: fast case-folding or character-set translation tables.
* **Example:**
  ```assembly
  MOV BX, OFFSET UpperCaseTable  ; 256-byte table mapping byte -> uppercase
  MOV AL, 'a'
  XLAT                            ; AL = 'A'
  ```
* **Flags Affected:** Unchanged

---

### XOR
* **Opcode:** `30-35`, `80`/`81`/`83` `/6`
* **Operands:** `REG, memory` | `memory, REG` | `REG, REG` | `memory, immediate` | `REG, immediate`
* **Description:** Bitwise Logical Exclusive OR. `XOR reg, reg` is the idiomatic, smallest-encoding way to zero a register (and also clears `CF`/`OF`, unlike `MOV reg, 0` which leaves flags untouched — worth knowing if code after it branches on flags).
* **Example:**
  ```assembly
  XOR AX, AX     ; AX = 0, in 2 bytes instead of 3 for MOV AX, 0
  ```
* **Flags Affected:** `C:0`, `O:0`, `Z:r`, `S:r`, `P:r`, `A:?`

---

## Conditional Jumps (Jcc)

All conditional jumps are **short** only on the real 8086 (`7x` opcode + signed 8-bit displacement, range ±127 bytes) except `JCXZ` (`E3`), which is also short-only. There is no native near/far conditional jump on 8086 — to branch further away, invert the condition and jump over an unconditional `JMP`:
```assembly
JNE SkipFar
JMP FarTarget
SkipFar:
```

| Mnemonic(s) | Opcode | Condition tested | Meaning (typical use after `CMP`) |
|---|---|---|---|
| `JE` / `JZ` | `74` | `ZF=1` | equal / zero |
| `JNE` / `JNZ` | `75` | `ZF=0` | not equal / not zero |
| `JG` / `JNLE` | `7F` | `ZF=0 and SF=OF` | greater (signed) |
| `JGE` / `JNL` | `7D` | `SF=OF` | greater-or-equal (signed) |
| `JL` / `JNGE` | `7C` | `SF≠OF` | less (signed) |
| `JLE` / `JNG` | `7E` | `ZF=1 or SF≠OF` | less-or-equal (signed) |
| `JA` / `JNBE` | `77` | `CF=0 and ZF=0` | above (unsigned greater) |
| `JAE` / `JNB` / `JNC` | `73` | `CF=0` | above-or-equal (unsigned) / no carry |
| `JB` / `JNAE` / `JC` | `72` | `CF=1` | below (unsigned) / carry set |
| `JBE` / `JNA` | `76` | `CF=1 or ZF=1` | below-or-equal (unsigned) |
| `JO` | `70` | `OF=1` | overflow set |
| `JNO` | `71` | `OF=0` | overflow clear |
| `JS` | `78` | `SF=1` | sign set (negative result) |
| `JNS` | `79` | `SF=0` | sign clear (non-negative result) |
| `JP` / `JPE` | `7A` | `PF=1` | parity even |
| `JNP` / `JPO` | `7B` | `PF=0` | parity odd |
| `JCXZ` | `E3` | `CX=0` | jump if `CX` register is zero (not a flag test!) |

**Signed vs. unsigned matters:** always use the `JG/JL/JGE/JLE` family after comparing signed quantities, and the `JA/JB/JAE/JBE` family after comparing unsigned quantities. Using the wrong family is a very common bug — e.g. comparing `0FFFFh` (as unsigned 65535, or signed -1) against `1` gives opposite `JG` vs `JA` results.

* **Example:**
  ```assembly
  MOV AX, -1        ; 0FFFFh
  CMP AX, 1
  JG  SignedGreater ; NOT taken: -1 is not > 1 (signed)
  JA  UnsignedAbove ; taken: 0FFFFh is > 1 (unsigned)
  ```
* **Flags Affected:** Unchanged (jumps only read flags/`CX`, never write them)

---

## LOOP / LOOPE / LOOPZ / LOOPNE / LOOPNZ

* **Opcode:** `E2` (`LOOP`) | `E1` (`LOOPE`/`LOOPZ`) | `E0` (`LOOPNE`/`LOOPNZ`)
* **Operands:** `short-label` (±127 bytes, same range restriction as `Jcc`)
* **Description:** Decrements `CX` by 1 (without affecting flags), then jumps to the label if `CX != 0` (`LOOP`), or if `CX != 0` **and** `ZF=1` (`LOOPE`/`LOOPZ`), or if `CX != 0` **and** `ZF=0` (`LOOPNE`/`LOOPNZ`). Combines a counter decrement and conditional branch into a single compact instruction — the idiomatic 8086 `for` loop.
* **Example:**
  ```assembly
  MOV CX, 10
  MOV SI, OFFSET Data
  SumLoop:
      ADD AX, [SI]
      ADD SI, 2
      LOOP SumLoop     ; decrement CX, loop while CX <> 0
  ```
* **Flags Affected:** Unchanged (`CX` is decremented, but no flag bits are touched)

---

## Appendix A: Instruction Categories vs. Flag Effects — Quick Legend
* `r` — flag is **r**eplaced/set according to the true result of the operation.
* `0` / `1` — flag is unconditionally cleared/set, regardless of operand values.
* `?` — flag is left in an **undefined** state; never branch on it afterward without first explicitly setting it.
* *(unchanged)* — the instruction does not touch this flag at all, whatever its prior value was.

## Appendix B: Segment Override Prefixes
Any memory operand's default segment (`DS`, or `SS` for `BP`-based addressing) can be overridden with a 1-byte prefix immediately before the instruction: `2E` (`CS:`), `36` (`SS:`), `3E` (`DS:`), `26` (`ES:`). String destination operands addressed via `DI` are the one exception — they are **always** `ES:[DI]` and cannot be overridden; the source side (`DS:[SI]`) can be.
```assembly
MOV AX, ES:[BX]   ; read through ES instead of the default DS
```

## Appendix C: 8086 vs. Later Extensions Cheat-Sheet
| Feature | 8086/8088 | First appears in |
|---|---|---|
| `PUSHA` / `POPA` | ✗ | 80186 |
| `BOUND` | ✗ | 80186 |
| `ENTER` / `LEAVE` | ✗ | 80186 |
| Immediate shift/rotate count (`SHL reg, 4`) | ✗ (only `1` or `CL`) | 80186 |
| `IMUL reg, rm, imm` (2/3-operand form) | ✗ (only 1-operand `IMUL`) | 80186 |
| `PUSH imm` | ✗ | 80186 |
| Protected mode, `LGDT`/`LIDT`/etc. | ✗ | 80286 |
| 32-bit registers (`EAX`, ...) | ✗ | 80386 |
