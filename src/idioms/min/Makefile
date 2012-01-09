all: minasm.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o minasm -lc minasm.o
minasm.o: minasm.s
	as -gstabs -o minasm.o minasm.s
clean:
	@rm -f *.o minasm

