section .multiboot_header
header_start:
    ; dd is define double (32-bit)
    dd 0xe85250d6                ; magic number for multi-boot 2
    dd 0                         ; set architecture to 0(protected mode i386)
    dd header_end - header_start ; header length
    ; checksum
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

    ; required end tag
    ; dw is define word (16-bit)
    dw 0    ; type
    dw 0    ; flags
    dd 8    ; size
header_end: