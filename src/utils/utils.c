#include "utils.h"

void outb(uint16_t port, uint8_t value) {
    // a mean the the value is in the AL register
    __asm__ volatile("outb %0, %1" : : "a"(value), "Nd"(port));
}

uint8_t inb(uint16_t port) {
    uint8_t value;

    __asm__ volatile("inb %1, %0" : "=a"(value) : "Nd"(port));

    return value;
}

void io_wait(void) { // delay for I/O operation

    __asm__ volatile("outb %%al, $0x80" : : "a"(0));
}