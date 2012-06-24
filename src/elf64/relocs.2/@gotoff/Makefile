all: libreloc.so libsyms.so relocapp 

relocapp: relocapp.c
	gcc -O2 -o relocapp -L. -lsyms -lreloc -L../.. -lself relocapp.c

libsyms.so: libsyms.c
	gcc -O2 -fpic -shared --save-temps -o libsyms.so libsyms.c

libreloc.so: libreloc.o
	gcc -shared -o libreloc.so -lc libreloc.o

libreloc.o: libreloc.s
	as -o libreloc.o libreloc.s

clean:
	rm -f *.o *.i *.so relocapp
