ENTRY(start)

SECTIONS{
    . = 1048576;
    .boot :
    {
        KEEP(*(.multiboot_header))
    }

    .text :
    {
        *(.text .text.*)
    }

    .rodata :
    {
        *(.rodata .rodata.*)
    }

    .data.rel.ro :
    {
        *(data.rel.ro.local*) *(.data.rel.ro .data.rel.ro.*)
    }

}