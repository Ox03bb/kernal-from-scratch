#include "vga_lib.h"
#include "vga.h"

/*
 * Logging
 */

void vga_log_info(const char *str0, const char *str, const char *str2) {
    vga_print(str0);

    vga_set_color(BLUE, DEFUALT_B);

    vga_print(str);

    vga_set_color(DEFUALT_F, DEFUALT_B);

    vga_print(str2);
}

void vga_log_success(const char *str0, const char *str, const char *str2) {
    vga_print(str0);

    vga_set_color(GREEN, DEFUALT_B);

    vga_print(str);

    vga_set_color(DEFUALT_F, DEFUALT_B);

    vga_print(str2);
}

void vga_log_warning(const char *str0, const char *str, const char *str2) {
    vga_print(str0);

    vga_set_color(BROWN, DEFUALT_B);

    vga_print(str);

    vga_set_color(DEFUALT_F, DEFUALT_B);

    vga_print(str2);
}

void vga_log_error(const char *str0, const char *str, const char *str2) {
    vga_print(str0);

    vga_set_color(RED, DEFUALT_B);

    vga_print(str);

    vga_set_color(DEFUALT_F, DEFUALT_B);

    vga_print(str2);
}

/*
 * Text utilities
 */

void vga_println(const char *str) {
    vga_print(str);
    vga_newline();
}

void vga_print_at_end(const char *str) {
    uint8_t length = 0;

    while (str[length] != '\0')
        length++;

    if (length >= VGA_WIDTH)
        length = VGA_WIDTH;

    vga_set_cursor(VGA_WIDTH - length, vga_get_cursor_y());
    vga_print(str);
}

void vga_print_at_end_c(const char *str, uint8_t color) {

    vga_set_color(color, DEFUALT_B);
    vga_print_at_end(str);
    vga_set_color(DEFUALT_F, DEFUALT_B);
}

void vga_print_line_at(uint8_t row, const char *str) {
    if (row >= VGA_HEIGHT)
        return;

    vga_set_cursor(0, row);
    vga_print(str);
}

void vga_print_centered(const char *str, uint8_t row) {
    uint8_t length = 0;

    if (row >= VGA_HEIGHT)
        return;

    while (str[length] != '\0')
        length++;

    if (length >= VGA_WIDTH)
        length = VGA_WIDTH;

    uint8_t x = (VGA_WIDTH - length) / 2;

    vga_set_cursor(x, row);
    vga_print(str);
}

/*
 * Screen utilities
 */

void vga_clear_line(uint8_t row) {
    if (row >= VGA_HEIGHT)
        return;

    vga_set_cursor(0, row);

    for (uint8_t x = 0; x < VGA_WIDTH; x++)
        vga_print_char(' ');
}

void vga_clear_screen(void) { vga_clear(); }

/*
 * Cursor utilities
 */

void vga_newline(void) {
    uint8_t y = vga_get_cursor_y();

    if (y < VGA_HEIGHT - 1) {
        vga_set_cursor(0, y + 1);
    }
}

void vga_home(void) { vga_set_cursor(0, 0); }