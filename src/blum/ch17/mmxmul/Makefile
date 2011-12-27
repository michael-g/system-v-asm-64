all: mmxmul.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o mmxmul -lc mmxmul.o

mmxmul.o: mmxmul.s
	as -gstabs -o mmxmul.o mmxmul.s

clean:
	@$(RM) *.o mmxmul

