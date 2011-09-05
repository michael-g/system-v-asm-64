
all: dents

dents: dents.o
	ld -melf_i386 --dynamic-linker /lib/ld-linux.so.2 -o dents -lc dents.o 
#	ld -melf_i386 --dynamic-linker /lib/ld-linux.so.2 -o dents -lc dents.o ../asmlib/mglib.o

dents.o:
	as --32 -g -o dents.o dents.s

clean:
	rm *.o dents
