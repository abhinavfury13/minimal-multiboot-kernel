arch := x86_64
kernel := build/$(arch)/kernel.bin
iso := build/$(arch)/os.iso

linker_script := src/arch/$(arch)/link.ld
grub_cfg := src/arch/$(arch)/grub.cfg
assembly_source_files := $(wildcard src/arch/$(arch)/*.asm)
assembly_object_files := $(patsubst src/arch/$(arch)/%.asm, build/$(arch)/%.o, $(assembly_source_files))

.PHONY: all clean run iso

all: $(kernel)

clean: 
	@rm -r build

run: $(iso)
	@qemu-system-x86_64 -cdrom $(iso)

iso: $(iso)

$(iso): $(kernel) $(grub_cfg)
	@mkdir -p build/$(arch)/isofiles/boot/grub
	@cp $(kernel) build/$(arch)/isofiles/boot/kernel.bin
	@cp $(grub_cfg) build/$(arch)/isofiles/boot/grub
	@grub-mkrescue -o $(iso) build/$(arch)/isofiles 2> /dev/null

$(kernel): $(assembly_object_files) $(linker_script)
	@ld -n -T $(linker_script) -o $(kernel) $(assembly_object_files)

#compile assembly object files
build/$(arch)/%.o: src/arch/$(arch)/%.asm	
	@mkdir -p $(shell dirname $@)
	@nasm -f elf64 $< -o $@