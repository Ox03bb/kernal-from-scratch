; ============================================================
; IRQ handlers 0-15
;
; PIC IRQs:
;   IRQ 0  -> IDT vector 32
;   IRQ 1  -> IDT vector 33
;   ...
;   IRQ 15 -> IDT vector 47
;
; The IDT uses vectors 32-47, but we pass IRQ numbers
; 0-15 to the C IRQ handler.
; ============================================================

[BITS 32]


; ============================================================
; Export IRQ handlers and IRQ table
; ============================================================

global irq0
global irq1
global irq2
global irq3
global irq4
global irq5
global irq6
global irq7
global irq8
global irq9
global irq10
global irq11
global irq12
global irq13
global irq14
global irq15

global irq_table


extern irq_handler


; ============================================================
; IRQ macro
;
; IRQs do NOT automatically push an error code.
;
; We push:
;
;   1. dummy error code
;   2. IRQ number
;
; This gives us a predictable stack layout.
; ============================================================

%macro IRQ 1

irq%1:

    cli

    push dword 0        ; dummy error code
    push dword %1       ; IRQ number: 0-15

    jmp irq_common_stub

%endmacro


; ============================================================
; IRQ entry points
; ============================================================

IRQ 0
IRQ 1
IRQ 2
IRQ 3
IRQ 4
IRQ 5
IRQ 6
IRQ 7
IRQ 8
IRQ 9
IRQ 10
IRQ 11
IRQ 12
IRQ 13
IRQ 14
IRQ 15


; ============================================================
; IRQ table
;
; irq_table[0]  -> irq0
; irq_table[1]  -> irq1
; ...
; irq_table[15] -> irq15
; ============================================================

section .data

irq_table:
    dd irq0
    dd irq1
    dd irq2
    dd irq3
    dd irq4
    dd irq5
    dd irq6
    dd irq7
    dd irq8
    dd irq9
    dd irq10
    dd irq11
    dd irq12
    dd irq13
    dd irq14
    dd irq15


; ============================================================
; Common IRQ stub
; ============================================================

section .text

irq_common_stub:

    ; Save general-purpose registers
    pusha

    ; Pass pointer to interrupt frame
    push esp
    call irq_handler
    add esp, 4

    ; Restore general-purpose registers
    popa

    ; Remove:
    ;
    ;   4 bytes = IRQ number
    ;   4 bytes = dummy error code
    ;
    add esp, 8

    iretd