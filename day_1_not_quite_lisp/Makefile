EXES = main
ASFLAGS = -g --32
LDFLAGS = -L . -rpath . -m elf_i386 -L/usr/lib32 -dynamic-linker /lib/ld-linux.so.2
LIBS = -lc

all: $(EXES)

$(EXES): %: %.o
	ld $(LDFLAGS) $< -o $@ $(LIBS)

%.o: %.s
	as $(ASFLAGS) $< -o $@

clean:
	rm -f $(EXES) *.o

run: main
	./main

.PHONY: all clean run
