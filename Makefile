arch := x86_64
kernel := build/$(arch)/kernel.bin
iso := build/$(arch)/os.iso

linker_script := src/arch/$(arch)/link.ld
grub_cfg := src/arch/$(arch)/grub.cfg
assembly_source_files := $(wildcard src/arch/$(arch)/*.asm)
assembly_object_files := $(patsubst src/arch/$(arch)/%.asm, build/$(arch)/%.o, $(assembly_source_files))

target ?= $(arch)-os_in_rust
rust_os := target/$(target)/debug/libos_in_rust.a

# build-std flag can be passed on nightly rust compilers
# we are rebuilding the core and compiler_builtins library for our custom target
# we are using the compiler-builtins-mem functions which contains all the memcpy, memmove etc. functions with no_mangle so linker can see them
rust_compiler_flags := -Z build-std=core,compiler_builtins -Z build-std-features=compiler-builtins-mem

.PHONY: all clean run iso debug

all: $(kernel)

clean: 
	@rm -r build
	@rm -r target

run: $(iso)
	@qemu-system-x86_64 -cdrom $(iso)

debug: $(iso)
	@qemu-system-x86_64 -s -S -cdrom $(iso)

iso: $(iso)

$(iso): $(kernel) $(grub_cfg)
	@mkdir -p build/$(arch)/isofiles/boot/grub
	@cp $(kernel) build/$(arch)/isofiles/boot/kernel.bin
	@cp $(grub_cfg) build/$(arch)/isofiles/boot/grub
	@grub-mkrescue -o $(iso) build/$(arch)/isofiles 2> /dev/null

$(kernel): kernel $(rust_os) $(assembly_object_files) $(linker_script)
	@ld -n -T $(linker_script) -o $(kernel) $(assembly_object_files) $(rust_os)

kernel:
	@RUST_TARGET_PATH= cargo build --target $(target).json $(rust_compiler_flags)

#compile assembly object files
build/$(arch)/%.o: src/arch/$(arch)/%.asm	
	@mkdir -p $(shell dirname $@)
	@nasm -f elf64 $< -o $@
