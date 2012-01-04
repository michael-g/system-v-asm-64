all: sse2math.o haddpd.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o sse2math -lc sse2math.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o haddpd -lc haddpd.o

sse2math.o: sse2math.s haddpd.s
	as -gstabs -o sse2math.o sse2math.s
	as -gstabs -o haddpd.o haddpd.s

clean:
	@rm -f *.o sse2math haddpd

