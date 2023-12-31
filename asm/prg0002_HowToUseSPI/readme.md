<!-- $Id: readme.md 1550 2023-12-16 06:01:32Z sow $ -->
# prg0002_HowToUseSPI

----

# Describe:
This program controls the SPI on MapperZeroAir.

# Point:
The SPI is assigned to triple latches that can update via $6000 in CPU address map. [CSx,MOSI,CLK] is assigned to CPU data bus [2:0]. 'SPI_BUS_RESET' and 'SPI_SEND_A_BYTE' in 'prg0002_HowToUseSPI.asm' control [CSx,MOSI,CLK] for transmit data to HOST.

# Note:
CPU address map $6000 is shared between SPI and LED on MapperZeroAir. When CLK goes HIGH, the LED will turn on.

