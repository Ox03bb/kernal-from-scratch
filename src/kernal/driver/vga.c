#include "vga.h"
#include "utils.h"

void vga_cursor_enable(void) {
    outb(VGA_INDEX_PORT, VGA_CURSOR_START);
    outb(VGA_DATA_PORT, 0x06);

    outb(VGA_INDEX_PORT, VGA_CURSOR_END);
    outb(VGA_DATA_PORT, 0x07);
}

void vga_cursor_disable(void) {
    outb(VGA_INDEX_PORT, VGA_CURSOR_START);
    outb(VGA_DATA_PORT, 0x20);
}

void vga_set_cursor(uint8_t x, uint8_t y) {
    uint16_t p = y * VGA_WIDTH + x;

    outb(VGA_INDEX_PORT, VGA_CURSOR_HIGH);
    outb(VGA_DATA_PORT, (p >> 8));

    outb(VGA_INDEX_PORT, VGA_CURSOR_LOW);
    outb(VGA_DATA_PORT, p & 0xff);
}

uint16_t vga_get_cursor_position(void) {

    outb(VGA_INDEX_PORT, VGA_CURSOR_HIGH);
    uint8_t p1 = inb(VGA_DATA_PORT);

    outb(VGA_INDEX_PORT, VGA_CURSOR_LOW);
    uint8_t p2 = inb(VGA_DATA_PORT);

    return ((uint16_t)p1 << 8) | p2;
}

uint8_t vga_get_cursor_x(void) { return vga_get_cursor_position() % VGA_WIDTH; }

uint8_t vga_get_cursor_y(void) { return vga_get_cursor_position() / VGA_WIDTH; }

void vga_clear(void) {
    volatile uint16_t *vga_buff = (uint16_t *)VGA_ADDRESS;

    vga_set_cursor(0, 0);

    for (int i = 0; i < VGA_RES; i++) {
        vga_buff[i] = ' ' | ((uint16_t)0 << 8);
    }

    vga_set_cursor(0, 0);
}
