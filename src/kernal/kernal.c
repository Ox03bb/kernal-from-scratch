#include "kernal.h"
#include "vga.h"

void kernal_main() { 
    vga_init();
    vga_print_char('k');
    vga_print_char('v');

    return; 
}