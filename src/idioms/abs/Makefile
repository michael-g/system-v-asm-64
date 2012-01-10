all: absasm.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o absasm -lc absasm.o

absasm.o: absasm.s
	as -gstabs -o absasm.o absasm.s

clean:
	@rm -f *.o absasm

