.PHONY: test clean

TARGET=MapperZeroAir.exe
INCDIR=../arduino/MapperZeroAir
TESTLOG=log

$(TARGET): $(TARGET:.exe=.c)
	$(CC) -Wall -I $(INCDIR) -o $@ $<

test: $(TARGET) size15byte.nes nonNesFile.nes mapper1.nes prg64kB.nes mapper0chr0kB.nes mapper2chr8kB.nes lessPrg.nes lessChr.nes mapper0.nes
	@echo -n "" > $(TESTLOG)
	@echo -n "TEST01: Illegal argument (don't supplied any argument) ... " && !(./$(TARGET) COM0 .nes --nmi > $(TESTLOG)) && echo "PASS"
	@echo -n "TEST02: The file name is too short.                    ... " && !(./$(TARGET) COM0 foo >> $(TESTLOG)) && echo "PASS"
	@echo -n "TEST03: The extention of file name is not match '.nes' ... " && !(./$(TARGET) COM0 foobar >> $(TESTLOG)) && echo "PASS"
	@echo -n "TEST04: Failed to load nes header.                     ... " && !(./$(TARGET) COM0 size15byte.nes >> $(TESTLOG)) && echo "PASS"
	@echo -n "TEST05: Nes header's prefix is broken.                 ... " && !(./$(TARGET) COM0 nonNesFile.nes >> $(TESTLOG)) && echo "PASS"
	@echo -n "TEST06: Nes header's mapper is not 0 or 2.             ... " && !(./$(TARGET) COM0 mapper1.nes >> $(TESTLOG)) && echo "PASS"
	@echo -n "TEST07: Nes header's PRG-ROM size is too large.        ... " && !(./$(TARGET) COM0 prg64kB.nes >> $(TESTLOG)) && echo "PASS"
	@echo -n "TEST08: Nes header's CHR-ROM size is too small.        ... " && !(./$(TARGET) COM0 mapper0chr0kB.nes >> $(TESTLOG)) && echo "PASS"
	@echo -n "TEST09: Nes header's CHR-ROM size is too large.        ... " && !(./$(TARGET) COM0 mapper2chr8kB.nes >> $(TESTLOG)) && echo "PASS"
	@echo -n "TEST10: Can't read PRG-ROM.                            ... " && !(./$(TARGET) COM0 lessPrg.nes >> $(TESTLOG)) && echo "PASS"
	@echo -n "TEST11: Can't read CHR-ROM.                            ... " && !(./$(TARGET) COM0 lessChr.nes >> $(TESTLOG)) && echo "PASS"
	@echo -n "TEST12: COM Port name is too long.                     ... " && !(./$(TARGET) COM123456789 mapper0.nes >> $(TESTLOG)) && echo "PASS"
	@echo -n "TEST13: Can't find COM Port.                           ... " && !(./$(TARGET) COM12345678 mapper0.nes >> $(TESTLOG)) && echo "PASS"
	@echo -n "TEST14: Too many arguments.                            ... " && !(./$(TARGET) COM0 foo.nes --irq bar >> $(TESTLOG)) && echo "PASS"

size15byte.nes:
	echo -n "0123456789ABCDE" > $@

nonNesFile.nes:
	echo -n "This is not NES header." > $@

mapper1.nes:
	echo "00000000: 4e45 531a 0000 1000 0000 0000 0000 0000" | xxd -r > $@

prg64kB.nes:
	echo "00000000: 4e45 531a 0400 2000 0000 0000 0000 0000" | xxd -r > $@

mapper0chr0kB.nes:
	echo "00000000: 4e45 531a 0100 0000 0000 0000 0000 0000" | xxd -r > $@

mapper2chr8kB.nes:
	echo "00000000: 4e45 531a 0101 2000 0000 0000 0000 0000" | xxd -r > $@

lessPrg.nes:
	echo "00000000: 4e45 531a 0100 2000 0000 0000 0000 0000" | xxd -r > $@

lessChr.nes:
	echo "00000000: 4e45 531a 0101 0000 0000 0000 0000 0000" | xxd -r > $@
	echo "00000000: 0000 0000 0000 0000 0000 0000 0000 0000" | xxd -r > _zero
	echo -n "" > __zero
	for item in {1..10}; do cat _zero _zero >> __zero; mv __zero _zero; done
	cat _zero >> $@
	rm -rf _zero

mapper0.nes: lessChr.nes
	cp $< $@
	xxd $< > _$@
	tail -512 _$@ | xxd -r - >> $@
	rm -rf _$@

clean:
	rm -rf $(TARGET)
	rm -rf $(TESTLOG) size15byte.nes nonNesFile.nes mapper1.nes prg64kB.nes mapper0chr0kB.nes mapper2chr8kB.nes lessPrg.nes lessChr.nes mapper0.nes

