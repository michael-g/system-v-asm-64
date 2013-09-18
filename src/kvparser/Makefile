all: kvparser.o
	ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -o kvparser -lc kvparser.o

kvparser.o: kvparser.s
	as -gstabs -o kvparser.o kvparser.s

clean:
	rm -f *.o kvparser

