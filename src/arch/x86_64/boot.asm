global start

section .text
bits 32
start:
    ; 48 65 6C 6C 6F 20 57 6F 72 6C 64 (hello world in hex)
    ;print Hello World to Screen
    mov dword [0xb8000], 0x2f652f48
    mov dword [0xb8004], 0x2f6c2f6c
    mov dword [0xb8008], 0x2f202f6f
    mov dword [0xb800b], 0x2f6f2f57
    mov dword [0xb8010], 0x2f6c2f72
    mov dword [0xb8014], 0x00002f64
    hlt