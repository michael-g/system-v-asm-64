all: setprec.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o setprec setprec.o

setprec.o: setprec.s
	as -gstabs -o setprec.o setprec.s

clean:
	@$(RM) setprec.o setprec
