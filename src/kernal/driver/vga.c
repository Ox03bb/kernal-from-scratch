#include "vga.h"
#include "utils.h"




void vga_set_cursor(uint8_t x, uint8_t y){
    uint16_t p = y * VGA_WIDTH + x;

    outb(VGA_INDEX_PORT, VGA_CURSOR_HIGH);
    outb(VGA_DATA_PORT, (p >> 8 ));

    outb(VGA_INDEX_PORT, VGA_CURSOR_LOW);
    outb(VGA_DATA_PORT, p & 0xff );
}



void vga_clear(void){
    volatile uint16_t *vga_buff = (uint16_t *)VGA_ADDRESS; 

    vga_set_cursor(0, 0)

    while( int i = 0 < VGA_RES; i ++){
        vga_buff[i] = ' ' | (uint16_t(0) >> 8 )
    }

    vga_set_cursor(0, 0)

}

