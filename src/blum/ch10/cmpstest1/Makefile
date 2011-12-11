all: cmptest.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o cmptest -lc cmptest.o

cmptest.o: cmptest.s
	as -gstabs -o cmptest.o cmptest.s

clean:
	@$(RM) *.o cmptest

