[BITS 32]

%macro ISR_NOERRCODE 1
global isr%1

extern isr_handler

isr%1:
    pusha

    push %1
    call isr_handler
    add esp, 4

    popa
    iret
%endmacro


; Generate ISR stubs
%assign i 0
%rep 256
    ISR_NOERRCODE i
%assign i i + 1
%endrep


; Generate ISR address table
section .data

global isr_table

isr_table:
%assign i 0
%rep 256
    dd isr%+i
%assign i i + 1
%endrep