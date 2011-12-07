all: convert.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o convert -lc convert.o

convert.o: convert.s
	as -gstabs -o convert.o convert.s

clean:
	@$(RM) *.o convert

