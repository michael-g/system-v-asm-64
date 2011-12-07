all: stostest.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o stostest -lc stostest.o

stostest.o: stostest.s
	as -gstabs -o stostest.o stostest.s

clean:
	@$(RM) *.o stostest

