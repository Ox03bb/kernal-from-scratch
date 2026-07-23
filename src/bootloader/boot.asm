[BITS 16]
[ORG 0x7C00]

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

KERNEL_LOAD_SEG equ 0x1000
KERNEL_START_ADDR equ 0x100000



;Load kernel
mov bx, KERNEL_LOAD_SEG
mov dh, 0x00
mov dl, 0x80
mov cl, 0x02
mov ch, 0x00
mov ah, 0x02
mov al, 8
int 0x13

jc disk_read_error


jmp start

msg db 13, 10,"Welcom to my bootLoader", 13, 10
    db "press any key to continue...", 0

s_msg db 13,10,10,"starting...",0    



%include "src/bootloader/utils.asm"


start:

call clear_screen


MOV si, msg 
call print

call get_key

MOV si, s_msg  ; Print starting msg
call print

jmp end


;Load kernel
mov bx, KERNEL_LOAD_SEG ; this is the segment where we want to load the kernel
mov dh, 0x00 ; head number
mov dl, 0x80 ; drive number
mov cl, 0x02 ; sector number
mov ch, 0x00 ; cylinder number
mov ah, 0x02 ; function 02h - read sectors
mov al, 8    ; number of sectors to read
int 0x13     ; int 13h - BIOS disk services

jc disk_read_error


PM_start:
    CLI
    LGDT[gdt_descriptor]
    MOV eax, cr0
    OR eax, 1
    MOV cr0, eax 

disk_read_error:
    hlt

%include "src/bootloader/gdt.asm"

end:
    JMP $


[BITS 32]

PM_main:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov ss, ax
    mov gs, ax
    mov ebp, 0x9C00
    mov esp, ebp

    in al, 0x92
    or al, 2
    out 0x92, al

times 510-($-$$) db 0 ;padding  
db 0x55, 0xAA