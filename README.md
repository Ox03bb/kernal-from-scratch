# kernal-from-scratch
An educational kernel built completely from scratch to explore low-level systems programming, memory management, interrupts, scheduling, and hardware interaction.



# Required Tools:
- [QEMU](https://www.qemu.org/) - An open-source emulator that allows you to run the kernel in a virtual environment.
- [GCC](https://gcc.gnu.org/) - The GNU Compiler Collection, used to compile the kernel code.
- [i686-elf-gcc](https://gcc.gnu.org/) - A cross-compiler for the i686 architecture, used to compile the kernel code for the target architecture.
- [NASM](https://www.nasm.us/) - The Netwide Assembler, used for assembling low-level assembly code.
- [GCC](https://gcc.gnu.org/) - The GNU Compiler Collection, used to compile the kernel code.
- [Make](https://www.gnu.org/software/make/) - A build automation tool that simplifies the compilation process.
- [GDB](https://www.gnu.org/software/gdb/) - The GNU Debugger, used for debugging the kernel during development.
- [PWNdbg](https://github.com/pwndbg/pwndbg) - A TUI debugger for GDB, providing an enhanced debugging experience.

To install all the required tools, you can use the following commands:

* **if u'r using Linux:**

    ```bash
        sh ./scripts/install.sh
    ```
* **if u'r using Windows:** (shame on you)

    1. Uninstall windows 
    2. Install linux
    3. Run the above command