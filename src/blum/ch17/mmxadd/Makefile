all: pmull.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o pmull -lc pmull.o

pmull.o: pmull.s
	as -gstabs -o pmull.o pmull.s

clean:
	@$(RM) *.o pmull

