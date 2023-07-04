#![no_std]
#![no_main]
#![feature(abi_x86_interrupt)]

mod vga_buffer;

use core::panic::PanicInfo;

pub mod interrupt;
pub mod gdt;

//We don't have a panic handler since we disabled the standard library
#[panic_handler]
fn panic(_info: &PanicInfo) -> !{ //! is an operator that means the function is diverging, never allowed to return
    println!("{}",_info);
    cpu_halt()
}

fn cpu_halt() -> !{
    loop{
        x86_64::instructions::hlt();
    }
}

fn init(){
    gdt::init_gdt();
    interrupt::init_idt();
    unsafe{
        interrupt::PICS.lock().initialize()
    };
    x86_64::instructions::interrupts::enable();
}

#[no_mangle] //We use no_mangle so that the compiler doesn't change the name of the function that we define
pub extern "C" fn rust_main() -> !{ //We need this to tell the linker the entry point
    clear_screen!();
    init();
    println!("Hello World");

    cpu_halt()
}
