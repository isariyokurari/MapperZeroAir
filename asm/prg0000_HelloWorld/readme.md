<!-- $Id: readme.md 1546 2023-12-15 14:03:57Z sow $ -->
# prg0000_HelloWorld

----

# Describe:
This program display 'Hello World!' at the center of screen.

# Point 1:
The program doesn't have CHR-ROM and works as like as mapper #2. Please assemble and download then reset Family Computer. After CHR-ROM image is downloaded from PRG-ROM to CHR-RAM, 'Hello World!' is displayed with blue BG and white Letter.

# Point 2:
Once you reset Family Computer after download, you can download and reset automaticaly from next time. This behavior is implemented by wait program on RAM and IRQ interrupt. Downloader 'MapperZeroAir.exe' send IRQ before download and after download. 'prg0000_HelloWorld' received first IRQ and goto wait program on RAM. The wait program wait next IRQ and after receive it the program go to the reset vector. While waiting next IRQ, the program is fetched from RAM, therefore running program is not broken by ROM update. After reset the downloaded program will run safely.

# Exercise 1:
Please modify source code from 'Hello World!' to 'Good Morning', then assemble it and download. After downloaded the program will run automatically.

# Exercise 2:
Please modify source code from 'Good Morning' to 'Hello World!', and turn FILL_CHR_ROM_EN to $00. This configure make the CHR-ROM transportation from PRG-ROM to CHR-RAM will skiiped. After ssemble it and downloaded, 'Hello World!' is displayed quickly. FILL_CHR_ROM_EN is useful to update just for program.

