all: msrtest

msrtest: msrtest.o
	gcc -o msrtest msrtest.o

msrtest.o: msrtest.c
	gcc -O2 -g -Wall -save-temps -c -o msrtest.o msrtest.c

clean:
	rm -f *.o *.i msrtest

#msrtest: msrtest.c
#	gcc -g -O2 -save-temps -Wall -I. -o msrtest -lc msrtest.c
#
#clean:
#	rm -f *.o *.i msrtest

