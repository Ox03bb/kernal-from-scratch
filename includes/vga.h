#ifndef VGA_H
#define VGA_H

#include <stdint.h>

#define VGA_ADDRESS 0xB8000

#define VGA_WIDTH  80
#define VGA_HEIGHT 25
#define VGA_RES    (VGA_HEIGHT * VGA_WIDTH)

#define VGA_INDEX_PORT 0x3D4
#define VGA_DATA_PORT  0x3D5

#define VGA_CURSOR_HIGH 0x0E
#define VGA_CURSOR_LOW  0x0F

#define VGA_CURSOR_START 0x0A
#define VGA_CURSOR_END   0x0B

#define BLACK      0 // DARK_GRAY
#define BLUE       1 // LIGHT_BLUE
#define GREEN      2 // LIGHT_GREEN
#define CYAN       3 // LIGHT_CYAN
#define RED        4 // LIGHT_RED
#define MAGENTA    5 // LIGHT_MAGENTA
#define BROWN      6 // YELLOW
#define LIGHT_GRAY 7 // WHITE

#define LIGHT_FLAG 8

typedef union vga_entry {
    uint16_t value;

    struct {
        uint8_t character;
        uint8_t attribute;
    };
} vga_entry;

void vga_init(void);

void vga_clear(void);

void vga_put_char(char c);

void vga_write(const char *str);

void vga_set_color(uint8_t foreground, uint8_t background);

void vga_cursor_enable(void);

void vga_cursor_disable(void);

void vga_set_cursor(uint8_t x, uint8_t y);

uint16_t vga_get_cursor_position(void);

uint8_t vga_get_cursor_x(void);

uint8_t vga_get_cursor_y(void);

#endif