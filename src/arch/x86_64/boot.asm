global start
global error
;these functions are defined in util.asm
extern check_multiboot
extern check_cpuid
extern check_longmode
section .text
bits 32
start:
    mov esp, stack_top

    call check_multiboot
    call check_cpuid
    call check_longmode


    ; 48 65 6C 6C 6F 20 57 6F 72 6C 64 (hello world in hex)
    ;print Hello World to Screen
    mov dword [0xb8000], 0x2f652f48
    mov dword [0xb8004], 0x2f6c2f6c
    mov dword [0xb8008], 0x2f202f6f
    mov dword [0xb800c], 0x2f6f2f57
    mov dword [0xb8010], 0x2f6c2f72
    mov dword [0xb8014], 0x00002f64
    hlt

        
;Prints Error: to the screen
;parameter: error code(in ascii) stored in al
error:
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte  [0xb800a], al
    hlt 



section .bss
stack_bottom:
    ;allocates 64 bytes, resb allocates 1 byte
    resb 64
stack_top:    