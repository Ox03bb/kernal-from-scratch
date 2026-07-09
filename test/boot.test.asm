org 0x7C00
bits 16

start:
    mov si, message

.print:
    lodsb               ; Load byte from [SI] into AL, SI++
    test al, al         ; Is it the null terminator?
    jz .hang

    mov ah, 0x0E        ; BIOS teletype output
    mov bh, 0x00        ; Display page
    mov bl, 0x07        ; Text attribute (light gray on black)
    int 0x10

    jmp .print

.hang:
    jmp .hang

HALT

message db "Hello, World!", 0

times 510 - ($ - $$) db 0
dw 0xAA55