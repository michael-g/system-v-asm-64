all: libtest.so test 

libtest.so: libtest.o
	gcc -shared -o libtest.so libtest.o

libtest.o: libtest.c
	gcc -O2 --save-temps -fPIC -c -o libtest.o libtest.c

test: test.o
	gcc -o test -L. -ltest test.o

test.o: test.c
	gcc -O2 --save-temps -c -o test.o test.c

clean:
	rm -f *.o *.i *.s *.so test 

