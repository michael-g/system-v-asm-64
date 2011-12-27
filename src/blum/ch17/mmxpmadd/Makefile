all: pmadd.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o pmadd -lc pmadd.o

pmadd.o: pmadd.s
	as -gstabs -o pmadd.o pmadd.s

clean:
	@$(RM) *.o pmadd

