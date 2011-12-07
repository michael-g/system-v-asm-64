all: reptest.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o reptest -lc reptest.o

reptest.o: reptest.s
	as -gstabs -o reptest.o reptest.s

clean:
	@$(RM) *.o reptest

