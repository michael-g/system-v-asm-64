all: stacktest.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o stacktest stacktest.o

stacktest.o: stacktest.s
	as -gstabs -o stacktest.o stacktest.s

clean:
	@$(RM) stacktest.o stacktest

