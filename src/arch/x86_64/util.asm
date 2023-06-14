global check_multiboot
global check_cpuid
global check_longmode
extern error
section .text
bits 32

; Util Function to check multiboot
check_multiboot:
    ;multiboot spec requires us to write this magic number before loading kernel
    cmp eax, 0x36d76289
    jne .no_multiboot
    ret

.no_multiboot:
    ; if the multiboot check fails we return with error code 0 in al register
    mov al, "0"
    jmp error

; Util Function to check if cpuid instruction is supported
check_cpuid:
    ; Check if CPUID is supported by attempting to flip the ID bit (bit 21)
    ; in the FLAGS register. If we can flip it, CPUID is available.

    ; Copy FLAGS in to EAX via stack
    pushfd
    pop eax

    ; Copy to ECX as well for comparing later on
    mov ecx, eax

    ; Flip the ID bit
    xor eax, 1 << 21

    ; Copy EAX to FLAGS via the stack
    push eax
    popfd

    ; Copy FLAGS back to EAX (with the flipped bit if CPUID is supported)
    pushfd
    pop eax

    ; Restore FLAGS from the old version stored in ECX (i.e. flipping the
    ; ID bit back if it was ever flipped).
    push ecx
    popfd

    ; Compare EAX and ECX. If they are equal then that means the bit
    ; wasn't flipped, and CPUID isn't supported.
    cmp eax, ecx
    je .no_cpuid
    ret
.no_cpuid:
    mov al, "1"
    jmp error       

; Util Function to check if longmode is supported
check_longmode:
    ; test if extended process info is available
    mov eax, 0x80000000 ; argument to cpu-id function passed to eax
    cpuid
    cmp eax, 0x80000001 ; we should check if value is at least 0x800000001
    jl .no_long_mode
    
    ; Now we use extended info to check if long mode is available
    mov eax, 0x80000001 ; argument to cpu-id function for extended info
    cpuid               ; loads extended info to ecx and edx registers
    test edx, 1 << 29   ; LM bit needs to be in edx register for long mode
    jz .no_long_mode    ; if not set, long mode unsupported
    ret 

.no_long_mode:
    mov al, "2"
    jmp error    