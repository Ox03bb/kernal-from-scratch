#ifndef IDT_H
#define IDT_H

#include <stdint.h>


#define IDT_ENTRIES 256

struct idt_entry {
    uint16_t offset_low;   // handler address bits 0..15
    uint16_t selector;     // code segment selector
    uint8_t  zero;         // must be 0
    uint8_t  type_attr;    // P, DPL, gate type
    uint16_t offset_high;  // handler address bits 16..31
} __attribute__((packed));

struct idtr {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

#endif