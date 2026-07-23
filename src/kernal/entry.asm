[BITS 32]

global _start
extern kernal_main

_start:
    call kernal_main
    cli
    hlt
    jmp $

