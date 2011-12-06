all: fscaletest.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o fscaletest -lc fscaletest.o

fscaletest.o: fscaletest.s
	as -gstabs -o fscaletest.o fscaletest.s

clean:
	@$(RM) fscaletest *.o

