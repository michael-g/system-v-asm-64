all: flogtest.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o flogtest -lc flogtest.o

flogtest.o: flogtest.s
	as -gstabs -o flogtest.o flogtest.s

clean:
	@$(RM) flogtest *.o

