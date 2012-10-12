all: msrtest

msrtest: msrtest.o
	gcc -o msrtest msrtest.o

msrtest.o: msrtest.c
	gcc -O2 -g -save-temps -c -o msrtest.o msrtest.c

clean:
	rm -f *.o *.i msrtest
