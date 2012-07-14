TDCDIR=../..
include $(TDCDIR)/software/common.mak

OBJECTS=_ashlsi3.o _divsi3.o _modsi3.o _udivmodsi4.o _umodsi3.o _ashrsi3.o _lshrsi3.o _mulsi3.o _udivsi3.o
OBJECTS+=libc.o crc16.o crc32.o console.o system.o irq.o vsnprintf-nofloat.o uart.o

all: libbase.a

# pull in dependency info for *existing* .o files
-include $(OBJECTS:.o=.d)

libbase.a: $(OBJECTS)
	$(AR) clr libbase.a $(OBJECTS)
	$(RANLIB) libbase.a

%.o: %.c
	$(compile-dep)

.PHONY: clean

clean:
	rm -f $(OBJECTS) $(OBJECTS:.o=.d) libbase.a .*~ *~
