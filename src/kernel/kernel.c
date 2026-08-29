#include "kernel.h"
#include "pic.h"
#include "idt.h"
#include "vga.h"
#include "utils.h"

void kernel_main() {

    vga_init();
    vga_print("[init] vga driver ... Ok\n");

    vga_print("[init] pic");
    pic_init();
    vga_print("        ... Ok\n");

    vga_print("[init] idt masks: ");
    idt_init();
    vga_print("... Ok\n");


    // pic_clear_mask(0);

    vga_print("[init] irq0 enabled\n");
    uint32_t before = read_eflags();

    sti();

    uint32_t after = read_eflags();

    vga_print("EFLAGS before: ");
    vga_print_hex(before);

    vga_print("\nEFLAGS after: ");
    vga_print_hex(after);

    asm volatile ("int $0x24"); 

    for (;;) {
        asm volatile ("cli");
    }
    
 
    return;
}
