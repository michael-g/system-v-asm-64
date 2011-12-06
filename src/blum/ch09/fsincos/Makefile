all: trigtest.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o trigtest -lc trigtest.o

trigtest.o: trigtest.s
	as -gstabs -o trigtest.o trigtest.s

clean:
	@$(RM) trigtest *.o

