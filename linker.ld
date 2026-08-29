ENTRY(_start)

OUTPUT_FORMAT(elf32-i386)
OUTPUT_ARCH(i386)

SECTIONS
{
    . = 0x00010000;

    .text : ALIGN(16)
    {
        KEEP(*(.text.start))
        *(.text)
        *(.text.*)
    }

    .rodata : ALIGN(16)
    {
        *(.rodata)
        *(.rodata.*)
    }

    .data : ALIGN(16)
    {
        *(.data)
        *(.data.*)
    }

    .bss : ALIGN(16)
    {
        *(COMMON)
        *(.bss)
        *(.bss.*)
    }
}