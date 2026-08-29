#include "isr.h"
#include "vga.h"

void isr_handler(uint32_t vector){
    vga_print("INT: ");
    vga_print_hex(vector);
    vga_print("\n");
     vga_print_hex(vector);

    for (;;)
        asm volatile ("hlt");
}
