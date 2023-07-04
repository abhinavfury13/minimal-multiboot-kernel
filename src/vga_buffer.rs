use volatile::Volatile;

#[allow(dead_code)]
#[derive(Debug, Clone, Copy, Eq, PartialEq)]
#[repr(u8)]
pub enum Colour{
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    Pink = 13,
    Yellow = 14,
    White = 15,
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
#[repr(transparent)]
struct ColourCode(u8);

impl ColourCode{
    fn new(foreground: Colour, background: Colour) -> ColourCode{
        //8 bytes, first four bytes represent foreground and last 4 bytes represent background colour
        ColourCode((background as u8) << 4 | (foreground as u8))
    }
}

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
#[repr(C)]
struct Character{
    character: u8,
    colour_code: ColourCode
}

const BUFFER_HEIGHT: usize = 25;
const BUFFER_WIDTH: usize = 80;

#[repr(transparent)]
struct Buffer{
    chars: [[Volatile<Character>; BUFFER_WIDTH]; BUFFER_HEIGHT]
}

pub struct Writer{
    row_position: usize,
    column_position: usize,
    colour_code: ColourCode,
    //static mutable because it's a reference to a physical buffer and it needs to be alive throughout the program runtime
    buffer: &'static mut Buffer
}

impl Writer{
    //writes a byte onto the screen
    pub fn write_byte(&mut self, byte: u8){
        match byte{
            b'\n' => self.new_line(),
            byte => {
                if self.column_position >= BUFFER_WIDTH{
                    self.new_line();
                }

                let row = self.row_position;
                let col = self.column_position;

                self.buffer.chars[row][col].write(Character{
                    character: byte,
                    colour_code: self.colour_code
                });

                self.column_position+=1;
            }
        }
    }

    pub fn new_line(&mut self)
    {
        self.column_position=0;
        let current_row = self.row_position;
        if current_row == BUFFER_HEIGHT - 1
        {
            //Move everything one line up
            for row in 1..BUFFER_HEIGHT{
                for column in 0..BUFFER_WIDTH{
                    let char = self.buffer.chars[row][column].read();
                    self.buffer.chars[row-1][column].write(char);
                }
            }
            self.clear_last_row();
        }
        else
        {
            self.row_position+=1;   
        }
    }

    pub fn clear_last_row(&mut self)
    {
        let last_row = BUFFER_HEIGHT - 1;
        for column in 0..BUFFER_WIDTH{
            self.buffer.chars[last_row][column].write(Character{
                        character: b' ',
                        colour_code: ColourCode::new(Colour::Black, Colour::Black)
                    });
        }
    }
    
    //Writes a string to screen
    pub fn write_string(&mut self, string: &str){
        for byte in string.bytes(){
            match byte {
                //Printable ascii characters are from 0x20 to 0x7e
                0x20..=0x7e | b'\n' => self.write_byte(byte),
                //Non Ascii characters which can't be printed
                _ => self.write_byte(0x03)
            }
        }
    }

    pub fn clear_screen(&mut self){
        for row in 0..BUFFER_HEIGHT{
            for col in 0..BUFFER_WIDTH{
                self.buffer.chars[row][col].write(Character{
                    character: b' ',
                    colour_code: ColourCode::new(Colour::Black, Colour::Black)
                });
            }
        }
        self.row_position = 0;
        self.column_position = 0;
    }
}

use lazy_static::lazy_static;
use spin::Mutex;
lazy_static!{
    pub static ref WRITER: Mutex<Writer> = Mutex::new(Writer{
    row_position: 0,
    column_position: 0,
    colour_code: ColourCode::new(Colour::Cyan, Colour::Black),
    buffer: unsafe{ &mut *(0xb8000 as *mut Buffer)}
    });
}
use core::fmt;
impl fmt::Write for Writer{
    fn write_str(&mut self, s: &str) -> fmt::Result {
        self.write_string(s);
        Ok(())
    }
}

//Defining macros

#[macro_export]
macro_rules! clear_screen {
    () => {
        ($crate::vga_buffer::_clear_screen())
    };
}

#[macro_export]
macro_rules! print {
    ($($arg:tt)*) => ($crate::vga_buffer::_print(format_args!($($arg)*)));
}

#[macro_export]
macro_rules! println {
    () => ($crate::print!("\n"));
    ($($arg:tt)*) => ($crate::print!("{}\n", format_args!($($arg)*)));
}

#[doc(hidden)]
pub fn _print(args: fmt::Arguments)
{
    use core::fmt::Write;

    x86_64::instructions::interrupts
        ::without_interrupts(||{
            WRITER.lock().write_fmt(args).unwrap()
        });
}

#[doc(hidden)]
pub fn _clear_screen()
{
    WRITER.lock().clear_screen();
}

