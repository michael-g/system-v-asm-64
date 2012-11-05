all: libpmc.so libkdbasm.so

libpmc.so: libpmc.o baseline.o kdbbridge.o
	ld --dynamic-linker=/lib64/ld-linux-x86-64.so.2 -shared -o libpmc.so -lc kdbbridge.o baseline.o libpmc.o

libkdbasm.so: kdbasm.s
	as -g -o kdbasm.o kdbasm.s
	ld --dynamic-linker=/lib64/ld-linux-x86-64.so.2 -shared -o libkdbasm.so -lc kdbasm.o 

kdbbridge.o: kdbbridge.c
	gcc -O2 -fpic -save-temps -c -g -o kdbbridge.o kdbbridge.c

baseline.o: baseline.c
	gcc -fpic -O0 -g -Wall -W -c -o baseline.o baseline.c

libpmc.o: libpmc.c msrdrv.h 
	gcc -fpic -O2 -g -Wall -W -c -o libpmc.o libpmc.c

clean:
	rm -f *.o *.i *.so

