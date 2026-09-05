#include "isr.h"
#include "vga.h"
#include "panic.h"

void isr_exeption_handler(uint32_t vector) {
    exception(EXCEPTIONS[vector]);
    vga_print("\n");

    for (;;)
        asm volatile("hlt");
}

void isr_handler(uint32_t vector) {
    if (vector <= 31) {
        isr_exeption_handler(vector);
    }

    vga_print("INT: ");
    vga_print_hex(vector);
    vga_print("\n");
}
