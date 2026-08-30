#include "lib/vga_lib.h"
#include "utils.h"
#include "vga.h"

void panic(char *err) {
    vga_log_error("", "\nKERNEL PANIC: ", err);

    cli();

    for (;;)
        hlt();
}