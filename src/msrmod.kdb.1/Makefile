all: libpmc.so

libpmc.so: libpmc.o testcode.o
	ld --dynamic-linker=/lib64/ld-linux-x86-64.so.2 -shared -fpic -o libpmc.so -lc testcode.o libpmc.o

testcode.o: testcode.c
	gcc -fpic -O0 -g -Wall -W -save-temps -c -o testcode.o testcode.c 

libpmc.o: libpmc.c msrdrv.h 
	gcc -fpic -O2 -g -Wall -W -save-temps -c -o libpmc.o libpmc.c

clean:
	rm -f *.o *.i *.so

