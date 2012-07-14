TDCDIR=../..
include $(TDCDIR)/software/common.mak

OBJECTS=crt0.o main.o stdc.o udelay.o temperature.o dac.o

all: demo.bin demo.h0 demo.h1 demo.h2 demo.h3

# pull in dependency info for *existing* .o files
-include $(OBJECTS:.o=.d)

demo.h0: demo.bin
	$(TDCDIR)/tools/bin2hex $< $@ 8192 4

demo.h1: demo.bin
	$(TDCDIR)/tools/bin2hex $< $@ 8192 3

demo.h2: demo.bin
	$(TDCDIR)/tools/bin2hex $< $@ 8192 2

demo.h3: demo.bin
	$(TDCDIR)/tools/bin2hex $< $@ 8192 1

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@
	chmod -x $@
	$(TDCDIR)/tools/crc32 $@ write

demo.elf: linker.ld libs $(OBJECTS)
	$(LD) $(LDFLAGS) -T linker.ld -N -o $@ $(OBJECTS) -L$(TDCDIR)/software/libbase -lbase
	chmod -x $@

libs:
	make -C $(TDCDIR)/software/libbase

.PHONY: clean libs

clean:
	rm -f *.o demo.elf demo.bin demo.h0 demo.h1 demo.h2 demo.h3 .*~ *~ Makefile.bak
