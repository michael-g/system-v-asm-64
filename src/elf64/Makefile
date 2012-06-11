all: libself.so selftest

libself.so: libself.o
	gcc -Wall -O2 -shared -o libself.so libself.o

libself.o: libself.c
	gcc -Wall -O2 -g -gdwarf-2 -fPIC --save-temps -c libself.c

selftest: selftest.c
	gcc -Wall -O2 -g -gdwarf-2 -c -o selftest.o selftest.c
	gcc -Wall -L. -lself -o selftest selftest.c


elfstat: elfstat.c
	gcc -Wall -O2 --save-temps -g -o elfstat -lc elfstat.c
clean:
	rm -f elfstat *.o *.s *.i *.so
