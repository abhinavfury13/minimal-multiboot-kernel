global long_mode_start

section .text
bits 64

long_mode_start:
    ; clear all the data segment registers
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; 48 65 6C 6C 6F 20 57 6F 72 6C 64 (hello world in hex)
    ;print Hello World to Screen
    mov rax, 0x2f6c2f6c2f652f48
    mov qword [0xb8000], rax
    mov rax, 0x2f6f2f572f202f6f
    mov qword [0xb8008], rax
    mov rax, 0x2f202f642f6c2f72
    mov qword [0xb8010], rax
    hlt