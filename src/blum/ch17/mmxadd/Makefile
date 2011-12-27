all: mmxadd.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o mmxadd -lc mmxadd.o

mmxadd.o: mmxadd.s
	as -gstabs -o mmxadd.o mmxadd.s

clean:
	@$(RM) *.o mmxadd

