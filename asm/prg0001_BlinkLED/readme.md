<!-- $Id: readme.md 1549 2023-12-16 05:57:53Z sow $ -->
# prg0001_BlinkLED

----

# Describe:
This program controls the LED on MapperZeroAir.

# Point:
The LED is assigned to a latch that can update via $6000 in CPU address map. When the CPU writes a value #$01 to address $6000 the LED turns on. If that write value is #$00 the LED turns off. 'prg0001_BlinkLED' make the LED blink by a simple program.

# Example:
Please modify source code from 'DIMMING_LED_EN  EQU $00' to 'DIMMING_LED_EN  EQU $01', then assemble it and download. After downloaded the program will run automatically and the LED blink slowly by dimming control.

