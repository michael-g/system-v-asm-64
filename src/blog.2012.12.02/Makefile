# (c) Michael Guyver, 2012, all rights reserved. Permission to use, copy, modify and distribute the 
# software is hereby granted for educational use which is non-commercial in nature, provided that 
# this copyright  notice and following two paragraphs are included in all copies, modifications and 
# distributions.
#
# THIS SOFTWARE AND DOCUMENTATION IS PROVIDED "AS IS," AND NO REPRESENTATIONS OR WARRANTIES ARE 
# MADE, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO, WARRANTIES OF MERCHANTABILITY OR 
# FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE SOFTWARE OR DOCUMENTATION WILL NOT 
# INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
#
# COPYRIGHT HOLDERS WILL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL OR CONSEQUENTIAL DAMAGES 
# ARISING OUT OF ANY USE OF THE SOFTWARE OR DOCUMENTATION.

all: libpmc.so libkdbavxor.so libkdbsseor.so

libpmc.so: libpmc.o baseline_asm.o
	ld --dynamic-linker=/lib64/ld-linux-x86-64.so.2 -shared -o libpmc.so -lc baseline_asm.o libpmc.o

libkdbavxor.so: kdbavxor.s savereg.macro.s kdbbridge.o
	as -g -o kdbavxor.o kdbavxor.s
	ld -shared --dynamic-linker=/lib64/ld-linux-x86-64.so.2 -o libkdbavxor.so -lc kdbbridge.o kdbavxor.o 

libkdbsseor.so: kdbsseor.s savereg.macro.s kdbbridge.o
	as -g -o kdbsseor.o kdbsseor.s
	ld --dynamic-linker=/lib64/ld-linux-x86-64.so.2 -shared -o libkdbsseor.so -lc kdbbridge.o kdbsseor.o 

libpmc.o: libpmc.c msrdrv.h 
	gcc -fpic -O2 -g -Wall -W -c -o libpmc.o libpmc.c

kdbbridge.o: kdbbridge.c
	gcc -fpic -O2 -g -Wall -W -c -o kdbbridge.o kdbbridge.c

baseline_asm.o: baseline_asm.s savereg.macro.s
	as -g -o baseline_asm.o baseline_asm.s

clean:
	rm -f *.o *.i *.so

