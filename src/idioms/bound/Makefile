all: bounds.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o bounds -lc bounds.o
bounds.o: bounds.s
	as -gstabs -o bounds.o bounds.s
clean:
	@rm -f *.o bounds

