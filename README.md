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

Picture of the CPU in Logism:

<img width="1481" height="892" alt="dsfdsfd" src="https://github.com/user-attachments/assets/f9b1baaa-7a1e-41a5-a2a7-e70c6de884f6" />

<img width="1505" height="677" alt="image" src="https://github.com/user-attachments/assets/f923c551-8b5f-492c-979e-d2820c3a96b3" />

<img width="1500" height="930" alt="image" src="https://github.com/user-attachments/assets/96d81dfc-e99d-4b88-b825-18ee03028909" />

<img width="1498" height="935" alt="image" src="https://github.com/user-attachments/assets/73393520-dbef-4098-9977-77c6741c2306" />

Picture of the GPU in Logism:

<img width="1492" height="730" alt="image" src="https://github.com/user-attachments/assets/345c5fec-11df-460e-98e8-dc14136b2fdf" />

<img width="1497" height="934" alt="image" src="https://github.com/user-attachments/assets/794e3a88-e5f2-42f6-84d4-5fe6571c8f03" />

<img width="1505" height="938" alt="image" src="https://github.com/user-attachments/assets/7203c10e-6b71-4079-b0cd-d90b82c8c0d5" />


