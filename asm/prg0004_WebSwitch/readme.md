<!-- $Id: readme.md 2265 2026-03-23 14:10:38Z sow $ -->
# prg0004_WebSwitch

----

# Describe:
This program loads web switch, controls web switch, controls a LED, and emulates a LED on screen.

# Point:
'prg0004_WebSwitch.asm' sences the pad I status and sends control commands to HOST progarm. If AUTO RELOAD is enabled, 'prg0004_WebSwitch.asm' will sends commands periodically.
HOST program 'prg0004_WebSwitch.py' access web page. To inform web switch status for MapperZeroAir, 'prg0004_WebSwitch.py' writes the status into $7FF8 on 32KByte PRG-ROM then issue IRQ. Therefore, 'prg0004_WebSwitch.asm' disables NMI and jumps to WRAM, then wait IRQ. Because CPU will access to PRG-ROM when IRQ is occured, IRQ must be disabled. Writing the web switch status to PRG-ROM is done safely because 6502 is running on WRAM without any PRG-ROM access.

# Note:
To run prg0004_WebSwitch.py, python 3.x is needed. Moreover, the modules 'serial' and 'requests' are needed. Please connect to network and run after edit URL, URL_ON, and URL_OFF.

