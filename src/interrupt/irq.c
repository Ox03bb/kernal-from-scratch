#include "irq.h"
#include "vga.h"
#include "vga_lib.h"

void irq_handler(uint32_t vector) {
    vga_print("IRQ: ");
    vga_print_hex(vector);
    vga_print("\n");
}