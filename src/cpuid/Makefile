all: avx brand msr msrtest family

avx: avx.o
	ld --dynamic-linker=/lib64/ld-linux-x86-64.so.2 -o avx -lc avx.o

avx.o: avx.s
	as -g -o avx.o avx.s

brand: brand.o
	ld --dynamic-linker=/lib64/ld-linux-x86-64.so.2 -o brand -lc brand.o

brand.o: brand.s
	as -g -o brand.o brand.s

msr: msr.o
	ld --dynamic-linker=/lib64/ld-linux-x86-64.so.2 -o msr -lc msr.o

msr.o: msr.s
	as -g -o msr.o msr.s

msrtest: msrtest.c
	gcc -save-temps -g -o msrtest -lc msrtest.c

family: family.o
	ld --dynamic-linker=/lib64/ld-linux-x86-64.so.2 -o family -lc family.o

family.o: family.s
	as -g -o family.o family.s

clean:
	rm -f brand avx msr msrtest *.o *.so

