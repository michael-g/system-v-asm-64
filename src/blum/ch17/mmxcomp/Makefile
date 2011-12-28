all: mmxcomp.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o mmxcomp -lc mmxcomp.o

mmxcomp.o: mmxcomp.s
	as -gstabs -o mmxcomp.o mmxcomp.s

clean:
	@rm -f *.o mmxcomp

