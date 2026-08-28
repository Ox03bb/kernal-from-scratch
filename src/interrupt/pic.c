#include "pic.h"


void pic_init(){
    out(PIC1_COMMAND, 0x11)
}



void pic_send_eoi(uint8_t irq) {
    if (irq >= 8) {
        outb(PIC2_COMMAND, PIC_EOI);
    }

    outb(PIC1_COMMAND, PIC_EOI);
}



void pic_remap(uint8_t offset1, uint8_t offset2)
{
    uint8_t master_mask;
    uint8_t slave_mask;

    // Save current interrupt masks
    master_mask = inb(PIC1_DATA);
    slave_mask  = inb(PIC2_DATA);

    // ICW1: begin initialization
    outb(PIC1_COMMAND, ICW1_INIT | ICW1_ICW4);
    io_wait();

    outb(PIC2_COMMAND, ICW1_INIT | ICW1_ICW4);
    io_wait();

    // ICW2: set vector offsets
    outb(PIC1_DATA, offset1);
    io_wait();

    outb(PIC2_DATA, offset2);
    io_wait();

    // ICW3: tell master about slave on IRQ2
    outb(PIC1_DATA, 0x04);
    io_wait();

    // ICW3: tell slave its cascade identity
    outb(PIC2_DATA, 0x02);
    io_wait();

    // ICW4: 8086 mode
    outb(PIC1_DATA, ICW4_8086);
    io_wait();

    outb(PIC2_DATA, ICW4_8086);
    io_wait();

    // Restore interrupt masks
    outb(PIC1_DATA, master_mask);
    outb(PIC2_DATA, slave_mask);
}

void irq_set_mask(uint8_t irq) {
    uint16_t port;
    uint8_t value;

    if(irq < 8) {
        port = PIC1_DATA;
    } else {
        port = PIC2_DATA;
        irq -= 8;
    }
    value = inb(port) | (1 << irq);
    outb(port, value);        
}

void pic_disable(void) {
    outb(PIC1_DATA, 0xff);
    outb(PIC2_DATA, 0xff);
}
