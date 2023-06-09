use x86_64::structures::idt::{InterruptDescriptorTable, InterruptStackFrame};
use crate::{println, print, gdt};
use pic8259::ChainedPics;
use spin;

pub const PIC_1_OFFSET: u8 = 32;
pub const PIC_2_OFFSET: u8 = PIC_1_OFFSET + 8;

pub static PICS: spin::Mutex<ChainedPics> = 
                    spin::Mutex::new(unsafe { ChainedPics::new(PIC_1_OFFSET, PIC_2_OFFSET)});

#[derive(Debug, Clone, Copy)]
#[repr(u8)]
pub enum InterruptIndex{
    Timer = PIC_1_OFFSET,
    Keyboard
}

impl InterruptIndex{
    fn as_u8(self) -> u8{
        self as u8
    }

    fn as_usize(self) -> usize{
        usize::from(self.as_u8())
    }
}

use lazy_static::lazy_static;
lazy_static!{
    static ref IDT: InterruptDescriptorTable = {
        let mut idt = InterruptDescriptorTable::new();
        idt.breakpoint.set_handler_fn(breakpoint_handler);
        // idt.double_fault.set_handler_fn(double_fault_handler);
        unsafe{
            idt.double_fault.set_handler_fn(double_fault_handler)
                .set_stack_index(gdt::DOUBLE_FAULT_IST_INDEX);
            //change stack when double fault occurs
        };
        idt[InterruptIndex::Timer.as_usize()].set_handler_fn(timer_interrupt_handler);
        idt[InterruptIndex::Keyboard.as_usize()].set_handler_fn(keyboard_interrupt_handler);
        idt
    };
}

pub fn init_idt(){
    IDT.load();
}

extern "x86-interrupt" fn breakpoint_handler(stack_frame: InterruptStackFrame){
    println!("Exception: Breakpoint!\n {:#?}", stack_frame);
    unsafe{
        *(0xdeadbeef as *mut u32) = 42;
    }
} 

extern "x86-interrupt" fn double_fault_handler(stack_frame: InterruptStackFrame, _error_code: u64) -> !{
    panic!("Exception: Double Fault!\n {:#?}", stack_frame);
} 

fn end_of_interrupt(interrupt_id: u8){
    unsafe{
        PICS.lock().notify_end_of_interrupt(interrupt_id)
    };
}

extern "x86-interrupt" fn timer_interrupt_handler(_stack_frame: InterruptStackFrame){
    print!(".");
    end_of_interrupt(InterruptIndex::Timer.as_u8());
}

use pc_keyboard::{layouts, DecodedKey, HandleControl, Keyboard, ScancodeSet1};
use spin::Mutex;
lazy_static!{
    static ref KEYBOARD: Mutex<Keyboard<layouts::Us104Key, ScancodeSet1>> = 
        Mutex::new(Keyboard::new(layouts::Us104Key, ScancodeSet1, HandleControl::Ignore));
}

fn handle_scancode(scancode: u8){
    let mut keyboard = KEYBOARD.lock();
    
    if let Ok(Some(key_event)) = keyboard.add_byte(scancode){
        if let Some(key) = keyboard.process_keyevent(key_event){
            match key{
                DecodedKey::Unicode(character) => print!("{}", character),
                DecodedKey::RawKey(key) => print!("{:?}", key)
            }
        }
    }
}



extern "x86-interrupt" fn keyboard_interrupt_handler(_stack_frame: InterruptStackFrame){
    
    use x86_64::instructions::port::Port;

    let mut port = Port::new(0x60);

    let scancode: u8 = unsafe{ port.read() };

    handle_scancode(scancode);

    end_of_interrupt(InterruptIndex::Keyboard.as_u8());
}