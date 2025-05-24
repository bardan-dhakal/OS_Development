# 📝 Bootloader Development Documentation (WSL + Bochs)

This document walks through the **entire process of writing, testing, and debugging a simple x86 bootloader** using NASM, Bochs, and WSL. It’s designed to help you or anyone recreate this from scratch.

---

## 📚 Table of Contents
1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Step-by-Step Bootloader Creation](#step-by-step-bootloader-creation)
   - [1️⃣ Writing the Bootloader](#1-writing-the-bootloader)
   - [2️⃣ Writing the Kernel](#2-writing-the-kernel)
   - [3️⃣ Assembling with NASM](#3-assembling-with-nasm)
   - [4️⃣ Creating the Floppy Image](#4-creating-the-floppy-image)
   - [5️⃣ Configuring Bochs](#5-configuring-bochs)
   - [6️⃣ Running and Debugging](#6-running-and-debugging)
4. [Common Errors and Fixes](#common-errors-and-fixes)
5. [Summary](#summary)

---

## 📖 Introduction
We built a **simple x86 bootloader** that:
- Runs at system startup (BIOS loads it from the first sector of a floppy)
- Prints messages to the screen
- Loads a small "kernel" into memory and jumps to it
- All developed and tested in **WSL (Windows Subsystem for Linux)** with **Bochs** as the x86 emulator.

---

## 🛠️ Prerequisites
- **WSL (Ubuntu)** with working `apt` setup
- **NASM**: `sudo apt install nasm`
- **Bochs**: `sudo apt install bochs bochs-x bochs-sdl`
- Basic familiarity with **x86 Assembly** and BIOS services (`int 10h`, `int 13h`)

---

## 🏗️ Step-by-Step Bootloader Creation

### 1️⃣ Writing the Bootloader (`bootstrap.asm`)
- Started with a bootloader that:
  - Sets up segment registers (important for DS, ES, etc.)
  - Displays a startup message using BIOS video interrupt (`int 10h`)
  - Loads one sector (the kernel) from floppy disk using BIOS disk interrupt (`int 13h`)
  - Jumps to the loaded kernel code at a known address
  - Contains the required **boot signature `0xAA55`** at offset 510–511
- **Key realization**: BIOS loads only sector 0 (512 bytes) to `0x7C00`. The bootloader must manually load the kernel sector.

### 2️⃣ Writing the Kernel (`test_kernel.asm`)
- A simple program that:
  - Prints a message to the screen
  - Halts in an infinite loop
- **Important**: Set `[org 0x0000]` in kernel code to match where it’s loaded into memory.

### 3️⃣ Assembling with NASM
```bash
nasm -f bin bootstrap.asm -o bootstrap.o
nasm -f bin test_kernel.asm -o test_kernel.o

### 4️⃣ Creating the Floppy Image
```bash
dd if=/dev/zero of=floppy.img bs=512 count=2880
dd if=bootstrap.o of=floppy.img conv=notrunc
dd if=test_kernel.o of=floppy.img bs=512 seek=1 conv=notrunc
```
**Note**: `seek=1` puts the kernel in sector 1.

---

### 5️⃣ Configuring Bochs (`bochsrc.txt`)
Initially encountered `ROM: System BIOS must end at 0xfffff`.

**Fix**: Use BIOS start at `0xE0000` to fit BIOS size (128KB) under 1MB.

```ini
romimage: file=/usr/share/bochs/BIOS-bochs-latest, address=0xE0000
vgaromimage: file=/usr/share/bochs/VGABIOS-lgpl-latest

floppya: 1_44=floppy.img, status=inserted
boot: a

log: OSDev.log
display_library: x
debug: action=ignore
```

---

### 6️⃣ Running and Debugging
```bash
make clean
make run
```
- Bochs starts the bootloader and loads the kernel.
- If stuck at debugger (`<bochs:1>`), type `c` to continue.

---

## 🚨 Common Errors and Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `ROM: System BIOS must end at 0xfffff` | BIOS file too large or misaligned | Use `address=0xE0000` for a 128KB BIOS |
| Stuck at BIOS jump `(invalid)` | BIOS file missing or misconfigured | Verify path and size of `BIOS-bochs-latest` |
| Debugger prompt `<bochs:1>` | Debug mode enabled | Add `debug: action=ignore` |
| GUI crashes in WSL | WSLg X11 instability | Use `display_library: sdl` or `nogui` |
| Kernel not running | Bootloader didn’t load sector 1 | Verify `int 13h` loads with `DL=0x00` |
| No print output | Incorrect segment setup or missing `int 10h` | Check `mov ax, 07C0h`, `mov ds, ax`, `mov ah, 0Eh` |

---

## 🔚 Summary
- Created a bootloader that loads a kernel and runs on Bochs + WSL.
- Debugged BIOS size errors and configured a valid `bochsrc.txt`.
- Confirmed kernel loading and output.
- Documented fixes for common pitfalls.

