all: msrtest

msrtest: msrtest.o
	ld --dynamic-linker=/lib64/ld-linux-x86-64.so.2 -o msrtest -lc msrtest.o

msrtest.o: msrtest.s
	as -64 -g -o msrtest.o msrtest.s

clean:
	rm -f *.o *.i msrtest
