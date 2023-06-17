#![no_std]
#![no_main]

use core::panic::PanicInfo;

//We don't have a panic handler since we disabled the standard library
#[panic_handler]
fn panic(_info: &PanicInfo) -> !{ //! is an operator that means the function is diverging, never allowed to return
    loop{}
}

#[no_mangle] //We use no_mangle so that the compiler doesn't change the name of the function that we define
pub extern "C" fn rust_main() -> !{ //We need this to tell the linker the entry point
    let x = ["Hello", "World", "!"];
    let _y = x;
    
    let buffer: *mut u8 = 0xb8000 as *mut u8; //we map the VGA Buffer address as a mutable pointer
    let text = b"My Own VGA Text Buffer!";
    let mut i=0;
    for &char in text{
        unsafe{
            *buffer.offset(i*2) = char; //The character to be printed
            *buffer.offset(i*2+1) = 0x2; //8-bit color
            i+=1;
        }
    }
        
    loop{}
}