all: ssecomp.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o ssecomp -lc ssecomp.o

ssecomp.o: ssecomp.s
	as -gstabs -o ssecomp.o ssecomp.s

clean:
	@rm -f *.o ssecomp

