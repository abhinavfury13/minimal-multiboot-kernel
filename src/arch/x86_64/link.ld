ENTRY(start)

SECTIONS{
    . = 100000000;
    .boot :
    {
        *(.multiboot_header)
    }

    .text :
    {
        *(.text)
    }
}