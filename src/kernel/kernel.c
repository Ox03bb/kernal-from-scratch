#include "kernel.h"
#include "pic.h"
#include "vga.h"

void kernel_main() {

    vga_init();
    vga_print("[init] vga driver ... Ok\n");

    vga_print("[init] pic");
    pic_init();
    vga_print("... Ok");

    return;
}