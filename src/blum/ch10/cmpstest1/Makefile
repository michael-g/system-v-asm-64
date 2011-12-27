all: cmpstest.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o cmpstest -lc cmpstest.o

cmpstest.o: cmpstest.s
	as -gstabs -o cmpstest.o cmpstest.s

clean:
	@$(RM) *.o cmpstest

