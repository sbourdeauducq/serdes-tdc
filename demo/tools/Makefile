TARGETS=bin2hex crc32

all: $(TARGETS)

%: %.c
	clang -O2 -Wall -I. -s -o $@ $<

.PHONY: clean

clean:
	rm -f $(TARGETS) *.o
