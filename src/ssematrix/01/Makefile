all: matrix.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o matrix -lc matrix.o
matrix.o: matrix.s
	as -gstabs -o matrix.o matrix.s
clean:
	@rm -rf *.o matrix

