Implementation of RISC-V CPU in SystemVerilog (tested on KC705 FPGA) and in Logism Evolution (a digital circuit simulator)

Specs:
- 32 bit RISC-V instructions
- 32 32-bit Registers. Register 0 is always 0.
- 32 bit 256 KB RAM with 4 banks
- Implementation of simple GPU that can take instructions to draw rectangles
- Implementation of TTY with polling and MMIO

Snake game example written in RISC-V and assembled to hex:

https://github.com/user-attachments/assets/abbb8b1b-15d1-4978-b6de-d2f52b5f29e0

TTY example written in RISC-V and assembled to hex (uses MMIO polling):

https://github.com/user-attachments/assets/4bbf83e8-264e-4881-8599-f2da4b0f7e07


