# x86 Assembly Revision Sheet

This document is intended as a **quick reference** for x86-64 assembly programming on Linux (NASM syntax).


# 1. CPU Overview

The CPU repeatedly performs the **Fetch → Decode → Execute** cycle.

```text
          +------------------+
          |   Instruction    |
          |      (RIP)        |
          +---------+---------+
                    |
               Fetch Instruction
                    |
               Decode Instruction
                    |
             Execute Instruction
                    |
               Update Registers
                    |
              Next Instruction
```

The CPU mainly works with:

* Registers
* Memory (RAM)
* Instructions
* Flags


# 2. Memory Layout of a Program

```text
High Address
+-----------------------+
| Command-line args     |
+-----------------------+
| Environment Variables |
+-----------------------+
| Stack                 |
| ↓ grows downward      |
+-----------------------+
|                       |
|      Free Space       |
|                       |
+-----------------------+
| Heap                  |
| ↑ grows upward        |
+-----------------------+
| .bss                  |
+-----------------------+
| .data                 |
+-----------------------+
| .rodata               |
+-----------------------+
| .text                 |
+-----------------------+
Low Address
```

### Sections

| Section   | Purpose                            |
| --------- | ---------------------------------- |
| `.text`   | Machine code                       |
| `.data`   | Initialized variables              |
| `.bss`    | Uninitialized variables            |
| `.rodata` | Read-only constants                |
| Heap      | Dynamic memory                     |
| Stack     | Local variables and function calls |


# 3. Registers

## General Purpose Registers

| Register | Purpose                            |
| -------- | ---------------------------------- |
| RAX      | Accumulator / Return value         |
| RBX      | General-purpose (callee-saved)     |
| RCX      | Counter                            |
| RDX      | Data / Multiply / Divide           |
| RSI      | Source pointer / 2nd argument      |
| RDI      | Destination pointer / 1st argument |
| RBP      | Base pointer                       |
| RSP      | Stack pointer                      |
| R8-R15   | Extra general-purpose registers    |


## Instruction Pointer

```text
RIP
```

Contains the address of the next instruction.


## Flags Register

```text
RFLAGS
```

Important flags:

| Flag | Meaning          |
| ---- | ---------------- |
| ZF   | Zero             | 
| CF   | Carry            |
| OF   | Overflow         |
| SF   | Sign             |
| IF   | Interrupt Enable |
| DF   | Direction        |

### Flag Roles:
- ZF: Set if the result of an operation is zero.
- CF: Set if there is a carry out of the most significant bit (for unsigned operations)
- OF: Set if there is a signed overflow.
- SF: Set if the result of an operation is negative.
- IF: Controls whether interrupts are enabled.
- DF: Determines the direction for string operations (increment or decrement).
  

## Segment Registers

```text
CS  # code segment
DS  # data segment
ES  # extra segment 
SS  # stack segment
FS  # extra segment
GS  # extra segment
```

Modern systems mainly use:

* FS
* GS


## Control Registers

Kernel only.

```text
CR0
CR2
CR3
CR4
```


# 4. Register Sizes

```text
64-bit

RAX

+-------------------------------+

32-bit

EAX

+---------------+

16-bit

AX

+-------+

8-bit

AH  AL
```

Example:

```asm
mov rax, 10
mov eax, 10
mov ax, 10
mov al, 10
```


# 5. Addressing Modes

## Immediate

```asm
mov rax, 5
```


## Register

```asm
mov rax, rbx
```


## Direct Memory

```asm
mov rax, [value]
```


## Register Indirect

```asm
mov rax, [rbx]
```


## Offset

```asm
mov rax, [rbx+8]
```


## Index

```asm
mov rax, [rbx+rcx]
```


## Scale

```asm
mov rax, [rbx+rcx*4]
```

Useful for arrays.


# 6. Data Sizes

| Size    | Name  |
| ------- | ----- |
| 8 bits  | byte  |
| 16 bits | word  |
| 32 bits | dword |
| 64 bits | qword |

Example:

```asm
mov byte [x],1
mov word [x],1
mov dword [x],1
mov qword [x],1
```


# 7. Basic Instructions

## MOV

```asm
mov rax,10
mov rbx,rax
```

Copies data.


## LEA

```asm
lea rax,[rbx+8]
```

Loads an **address**, not the value.


## Arithmetic

```asm
add rax,5
sub rax,2
inc rax
dec rax
neg rax
```


## Multiplication

Unsigned:

```asm
mul rbx
```

Signed:

```asm
imul rbx
```


## Division

Unsigned:

```asm
div rbx
```

Signed:

```asm
idiv rbx
```

Dividend:

```text
RDX:RAX
```


## Logical

```asm
and
or
xor
not
```

Example

```asm
xor rax,rax
```

Sets RAX to zero efficiently.


## Bit Shifts

```asm
shl rax,1
shr rax,1
sar rax,1
```


# 8. Comparison

```asm
cmp rax,rbx
```

Only updates flags.


# 9. Conditional Jumps

| Instruction | Meaning          |
| ----------- | ---------------- |
| je          | Equal            |
| jne         | Not equal        |
| jl          | Less             |
| jg          | Greater          |
| jle         | Less or equal    |
| jge         | Greater or equal |
| jb          | Below (unsigned) |
| ja          | Above (unsigned) |

Example

```asm
cmp rax,10
je equal
```


# 10. Unconditional Jump

```asm
jmp loop
```


# 11. Loops

```asm
mov rcx,5

loop_start:
    ; code
    loop loop_start
```


# 12. Stack

Top of stack:

```text
RSP
 ↓

+------+
| Data |
+------+
```

Push:

```asm
push rax
```

Pop:

```asm
pop rax
```


# 13. Function Calls

Call

```asm
call func
```

Return

```asm
ret
```

Typical function

```asm
func:
    push rbp
    mov rbp,rsp

    ; body

    mov rsp,rbp
    pop rbp
    ret
```


# 14. Linux Calling Convention (System V AMD64)

Arguments:

| Register | Argument |
| -------- | -------- |
| RDI      | 1        |
| RSI      | 2        |
| RDX      | 3        |
| RCX      | 4        |
| R8       | 5        |
| R9       | 6        |

Return value:

```text
RAX
```


# 15. Data Declaration

```asm
section .data

x db 10
y dw 100
z dd 1000
a dq 10000
```

| Directive | Size    |
| --------- | ------- |
| db        | 1 byte  |
| dw        | 2 bytes |
| dd        | 4 bytes |
| dq        | 8 bytes |


# 16. Reserve Memory

```asm
section .bss

buffer resb 64
array  resd 10
```

| Directive | Purpose        |
| --------- | -------------- |
| resb      | Reserve bytes  |
| resw      | Reserve words  |
| resd      | Reserve dwords |
| resq      | Reserve qwords |


# 17. String Instructions

```asm
movsb
movsw
movsd
movsq
```

Registers used:

```text
RSI → Source
RDI → Destination
RCX → Count (with REP)
```

Example

```asm
rep movsb
```


# 18. Common Assembly Directives

```asm
section .text
section .data
section .bss

global _start
extern printf
```

| Directive | Purpose        |
| --------- | -------------- |
| section   | Select section |
| global    | Export symbol  |
| extern    | Import symbol  |


# 19. Program Skeleton

```asm
section .data

msg db "Hello", 10
len equ $ - msg

section .text
global _start

_start:
    ; code

    mov rax, 60
    xor rdi, rdi
    syscall
```


# 20. Linux System Call

```asm
mov rax, SYS_write
mov rdi, 1
mov rsi, msg
mov rdx, len
syscall
```

Registers:

| Register | Meaning            |
| -------- | ------------------ |
| RAX      | System call number |
| RDI      | Argument 1         |
| RSI      | Argument 2         |
| RDX      | Argument 3         |
| R10      | Argument 4         |
| R8       | Argument 5         |
| R9       | Argument 6         |


# 21. Common System Calls (Linux x86-64)

| Call   | Number |
| ------ | ------ |
| read   | 0      |
| write  | 1      |
| open   | 2      |
| close  | 3      |
| mmap   | 9      |
| brk    | 12     |
| exit   | 60     |
| execve | 59     |


# 22. Building a NASM Program

```bash
nasm -f elf64 main.asm -o main.o
```

Link:

```bash
ld main.o -o program
```

Run:

```bash
./program
```


# 23. Frequently Used Commands

```asm
mov
lea

push
pop

call
ret

cmp  
test

jmp
je
jne
jg
jl

add
sub
inc
dec

mul
imul
div
idiv

and
or
xor
not

shl  ; shift left
shr  ; shift right
sar  ; shift arithmetic right


syscall
```