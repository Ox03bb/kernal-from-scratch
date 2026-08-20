#include "kernal.h"
#include "vga.h"

void kernal_main() { 

    vga_init();
    vga_print("Hi, this is kernel");
    
    return; 
}