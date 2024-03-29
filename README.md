# Minimal Multiboot Kernel

This is my attempt to learn Rust and Kernel Development and the intricate details involved in Systems Programming.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Building the Kernel](#building-the-kernel)
  - [Running the Kernel](#running-the-kernel)
- [Project Structure](#project-structure)
- [Usage and Examples](#usage-and-examples)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## Introduction

- This is a learning project for me to better understand the inner workings of kernel development
- This kernel targets the x86 architecture

## Features

- Basic memory management (page tables, heap allocation)
- Interrupt handling for keyboard and timer inputs
- Simple command-line interface or shell.

## Getting Started

### Prerequisites

- Rust Nightly Compiler
- QEMU

### Building the Kernel

To compile and build the kernel, follow these steps using the provided makefile:

1. **Building All Components:**
   Run the following command to build and run all components of the kernel:
 ```
 make all
 ```

2. **Cleaning Build Artifacts:**
  If needed, to clean the build artifacts, execute:
  ```
  make clean
  ```

3. **Build Kernel:**
  To build the kernel, execute:
  ```
  make kernel
  ```
  
### Running the Kernel

Once the kernel is built, you can run it using QEMU (assuming QEMU is installed) with the following command:
```
make run
```

## Project Structure

```
/
├── src/
│ ├── interrupt.rs # Contains interrupt handling code
│ ├── gdt.rs # Code for Global Descriptor Table (GDT)
│ ├── lib.rs # Common functionalities and library code
│ └── arch/
│ └── x86_64/ #Contains the bootloader
```


## Acknowledgements

This is based off of the 1st and 2nd edition of the blog by Phil Opperman.
