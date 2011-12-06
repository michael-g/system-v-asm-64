all: fcomtest.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o fcomtest -lc fcomtest.o

fcomtest.o: fcomtest.s
	as -gstabs -o fcomtest.o fcomtest.s

clean:
	@$(RM) fcomtest *.o

