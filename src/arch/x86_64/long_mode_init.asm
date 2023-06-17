global long_mode_start
extern rust_main

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

    ; calling the rust_main function in our staticlib
    call rust_main
    hlt