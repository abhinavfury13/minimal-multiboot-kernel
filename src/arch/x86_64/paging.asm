extern pml4_table
extern pdp_table
extern pd_table

global enable_paging
global set_up_page_tables

section .text
bits 32

set_up_page_tables:
    ;map first entry of pml4 to pdp table
    mov eax, pdp_table
    or eax, 0x3; present + writable bits
    mov [pml4_table], eax

    ;map first entry of pdp table to pd table
    mov eax,  pd_table
    or eax, 0b11; present + writable bits(0b is binary notation same as 0x3 in hex)
    mov [pdp_table], eax

    ;map each pd entry to huge page 2MiB
    mov ecx, 0 ;counter

.map_pd_table:
    ; map each entry of pd table to a huge page of size 2MiB, whose address is 2Mib * ecx
    mov eax, 0x200000           ; 2MiB
    mul ecx                     ; 2Mib * ecx stored at eax
    or eax, 0x83                ; present + writable + huge page (same as 0b10000011)
    mov [pd_table + ecx*8], eax ; map each entry of 8 bytes to the address stored in eax which has been calculated and the appropriate bits are set

    inc ecx                     
    cmp ecx, 512                ; if counter == 512, pd_table is fully mapped
    jne .map_pd_table           ; loop till all entries are mapped

    ret

enable_paging:
    ; point cr3 register(Page table base register) to pml4_table
    mov eax, pml4_table
    mov cr3, eax

    ; enable Physical Address Extension in CR4 register
    mov eax, cr4
    or eax, 1 << 5 ; Set 5th bit
    mov cr4, eax

    ; set the long mode bit in the EFER MSR
    mov ecx, 0xc0000080
    rdmsr               ; rdmsr reads the MSR whose address is specified by ECX and read into EDX:EAX
    or eax, 1 << 8
    wrmsr               ; wrmsr writes onto the register specified by ECX

    ; enable paging in CR0 register
    mov eax, cr0
    or eax, 1 << 31     ; bit 31 is paging enabled
    mov cr0, eax

    ret