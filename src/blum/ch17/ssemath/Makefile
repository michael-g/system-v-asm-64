all: ssemath.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o ssemath -lc ssemath.o

ssemath.o: ssemath.s
	as -gstabs -o ssemath.o ssemath.s

clean:
	@$(RM) *.o ssemath

