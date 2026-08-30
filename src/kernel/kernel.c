#include "kernel.h"
#include "idt.h"
#include "panic.h"
#include "pic.h"
#include "utils.h"
#include "vga.h"
#include "vga_lib.h"

void kernel_main() {

    vga_init();
    vga_log_info("[", "init", "] vga");
    vga_print_at_end_c("... Ok\n", GREEN);

    vga_log_info("[", "init", "] pic");
    pic_init();
    vga_print_at_end_c("... Ok\n", GREEN);

    vga_log_info("[", "init", "] idt");
    idt_init();
    vga_print_at_end_c("... Ok\n", GREEN);

    panic("testing panics");

    asm volatile("int $0x24");

    for (;;) {
        asm volatile("cli");
    }

    return;
}
