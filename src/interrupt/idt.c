#include "includes/idt.h"


static struct idt_entry idt[IDT_ENTRIES];
static struct idtr idtr;


void idt_set_gate(
    uint8_t vector,
    uint32_t handler,
    uint16_t selector,
    uint8_t type_attr
)
{
    idt[vector].offset_low  = handler & 0xFFFF;
    idt[vector].selector    = selector;
    idt[vector].zero        = 0;
    idt[vector].type_attr   = type_attr;
    idt[vector].offset_high = (handler >> 16) & 0xFFFF;
}