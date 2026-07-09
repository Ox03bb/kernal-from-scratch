ORG 0x7C00
bits 16

jmp _start

msg db "this is my bootLoader",0

_start:

print:
    MOV ah, 0x0E
    MOV si, msg
    loop:
        MOV al, [si]
        CMP al, 0
        JE loopend

        INT 0x10 
        INC si
        JMP loop

    loopend:
     
jmp $
times 510-($-$$) db 0
db 0x55, 0xAA