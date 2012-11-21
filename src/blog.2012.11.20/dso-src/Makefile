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

all: libbwcmp.so

libbwcmp.so: kdbasm.s 
	as -g -o kdbasm.o kdbasm.s
	ld --dynamic-linker=/lib64/ld-linux-x86-64.so.2 -shared -o libbwcmp.so -lc kdbasm.o 

clean:
	rm -f *.o *.i *.so

