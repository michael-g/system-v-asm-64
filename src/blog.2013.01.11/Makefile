all: harness libkdbipc.so

harness.o: harness.s
	as -g -o harness.o harness.s 

harness: harness.o libkdbipc.so
	ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -L. -o harness harness.o -lkdbipc

libkdbipc.so: kdb_ipc.o
	ld -shared -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o libkdbipc.so kdb_ipc.o -lc

kdb_ipc.o: kdb_ipc.s
	as -g -o kdb_ipc.o kdb_ipc.s

clean:
	rm -f *.o *.i test

