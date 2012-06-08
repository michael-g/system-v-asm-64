build: asmcrypt.o
	ld --dynamic-linker /lib64/ld-linux.so.2 -o asmcrypt asmcrypt.o

asmcrypt.o: asmcrypt.s
	as -gstabs -o asmcrypt.o asmcrypt.s

clean:
	@rm -f *.o asmcrypt

