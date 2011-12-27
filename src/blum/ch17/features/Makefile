all: features.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o features -lc features.o

features.o: features.s
	as -gstabs -o features.o features.s

clean:
	@$(RM) features *.o

