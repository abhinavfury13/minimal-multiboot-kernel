global start
global error
global pml4_table
global pdp_table
global pd_table

; these functions are defined in util.asm
extern check_multiboot
extern check_cpuid
extern check_longmode
; these functions are defined in paging.asm
extern set_up_page_tables
extern enable_paging
; function defined in long_mode_init.asm
extern long_mode_start

section .text
bits 32
start:
    mov esp, stack_top
    ; initial setup
    call check_multiboot
    call check_cpuid
    call check_longmode
    ; paging
    call set_up_page_tables
    call enable_paging

    ;load the 64-bit GDT
    lgdt [gdt64.pointer]

    jmp gdt64.code:long_mode_start

;Prints Error: to the screen
;parameter: error code(in ascii) stored in al
error:
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte  [0xb800a], al
    hlt

section .rodata
gdt64:
    dq 0                                                ; zero entry
    ; we define a code segment
    ; bit 43 - executable  (for code segment)
    ; bit 44 - code or data segment
    ; bit 47 - present
    ; bit 53 - 64-bit
.code: equ $ - gdt64
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53)    ; defining code segment
.pointer:
    dw $ - gdt64 - 1
    dq gdt64    

section .bss
align 4096
pml4_table:
    resb 4096
pdp_table:
    resb 4096
pd_table:
    resb 4096
stack_bottom:
    ;increase the size of the stack
    resb 4096 * 4
stack_top: