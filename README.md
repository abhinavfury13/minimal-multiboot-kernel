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

In-depth details about your kernel project:
- This is a learning project for me to better understand the inner workings of kernel development
- This kernel targets the x86 architecture

## Features

A comprehensive list of features your minimal kernel supports, such as:
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

A thorough overview of your project's directory structure:
```
/
├── bootloader/    # Contains bootloader code
├── kernel/        # Kernel source code
├── scripts/       # Build/run scripts
└── README.md      # Project README
```

Explain the purpose and content of each significant directory or file.

## Acknowledgements

This is based off of the 1st and 2nd edition of the blog by Phil Opperman.
