
vars: vars.o
	ld -melf_i386 --dynamic-linker /lib/ld-linux.so.2 -o vars -lc vars.o ../asmlib/mglib.o

vars.o:
	as --32 -o vars.o vars.s

