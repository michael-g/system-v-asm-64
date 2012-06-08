all: fsubtest.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o fsubtest -lc fsubtest.o

fsubtest.o: fsubtest.s
	as -gstabs -o fsubtest.o fsubtest.s

clean:
	rm -f *.o fsubtest

