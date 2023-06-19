#![no_std]
#![no_main]

mod vga_buffer;

use core::panic::PanicInfo;

//We don't have a panic handler since we disabled the standard library
#[panic_handler]
fn panic(_info: &PanicInfo) -> !{ //! is an operator that means the function is diverging, never allowed to return
    println!("{}",_info);
    loop{}
}

#[no_mangle] //We use no_mangle so that the compiler doesn't change the name of the function that we define
pub extern "C" fn rust_main() -> !{ //We need this to tell the linker the entry point
    clear_screen!();
    println!("Hello World");
    loop{}
}