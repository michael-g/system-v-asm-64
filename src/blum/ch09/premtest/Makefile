all: premtest.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o premtest -lc premtest.o

premtest.o: premtest.s
	as -gstabs -o premtest.o premtest.s

clean:
	@$(RM) premtest.o premtest

