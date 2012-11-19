all: libpmc.so libtest.so

libpmc.so: libpmc.o baseline.o
	ld --dynamic-linker=/lib64/ld-linux-x86-64.so.2 -shared -o libpmc.so -lc baseline.o libpmc.o

baseline.o: baseline.c
	gcc -fpic -O0 -g -Wall -W -c -o baseline.o baseline.c

libpmc.o: libpmc.c msrdrv.h 
	gcc -fpic -O2 -g -Wall -W -c -o libpmc.o libpmc.c

libtest.so: libtest.o
	ld --dynamic-linker=/lib64/ld-linux-x86-64.so.2 -shared -o libtest.so libtest.o

libtest.o: testcode.c
	gcc -fpic -O2 -g -Wall -W -c -o libtest.o testcode.c

clean:
	rm -f *.o *.i *.so

