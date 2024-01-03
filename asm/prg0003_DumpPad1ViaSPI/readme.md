<!-- $Id: readme.md 1590 2024-01-03 14:39:46Z sow $ -->
# prg0003_DumpPad1ViaSPI

----

# Describe:
This program dump PAD1 and notice it via SPI on MapperZeroAir.

# Point:
The SPI is assigned to triple latches that can update via $6000 in CPU address map. [CSx,MOSI,CLK] is assigned to CPU data bus [2:0]. 'SPI_BUS_RESET' and 'SPI_SEND_A_BYTE' in 'prg0003_DumpPad1ViaSPI.asm' control [CSx,MOSI,CLK] for transmit data to HOST.

# Note:
CPU address map $6000 is shared between SPI and LED on MapperZeroAir. When CLK goes HIGH, the LED will turn on.

