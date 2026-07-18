[ORG 0x7C00]

[BITS 16]

jmp _start

msg db 13, 10,"Welcom to my bootLoader", 13, 10
    db "press any key to continue...", 0

s_msg db 13,10,10,"starting...",0    




_start:

    mov ax, 0x0003
    int 0x10

    MOV bx, msg 
    MOV dx, 0  ;kernal start flag 


    print:
        MOV ah, 0x0E
        MOV si, bx
        loop:
            MOV al, [si]
            ; CMP al, '\n'  ; \ ascii code  
            ; JE newline 
            CMP al, 0
            JE .loop

            INT 0x10 
            INC si
            JMP loop

        .loop:


    CMP dx,1
    JE end

    MOV ah, 0x00
    INT 0x16

    MOV bx, s_msg  ; Print starting msg
    MOV dx,1 ; Enable kernal start flag 
    JMP print


    gdt_start:
        gdt_null:
            dq 0x0
        
        gdt_code:
            dw 0xFFFF       ; Limte
            dw 0x0000       ; Base
            db 0x00         ; Base
            db 10011010b    ; Access byte
            db 11001111b    ; Flags
            db 0x00         ; Base

        gdt_data:
            dw 0xFFFF       ; Limte
            dw 0x0000       ; Base
            db 0x00         ; Base
            db 10010010b    ; Access byte p=1 , DPL= 00 
            db 11001111b    ; Flags
            db 0x00         ; Base

    gdt_end:

    gdt_descriptor:
        dw gdt_end - gdt_start - 1 ; Size of GDT -1
        dd gdt_start 



    end:
        jmp $


    times 510-($-$$) db 0 ;padding  
    db 0x55, 0xAA