all: shared.so libcheat.so cheatapp

cheatapp: cheatapp.o
	gcc -Wall -O2 --save-temps -shared -o cheatapp cheatapp.o -L. -lcheat
cheatapp.o: cheatapp.c
	gcc -Wall -O2 --save-temps -fPIC -c -o cheatapp.o cheatapp.c


libcheat.so: libcheat.o
	gcc -O2 -Wall -shared --save-temps -o libcheat.so libcheat.o
libcheat.o: libcheat.c
	gcc -Wall -c -fPIC --save-temps -o libcheat.o libcheat.c
#	gcc -O2 -Wall -c -fPIC --save-temps -o libcheat.o libcheat.c
	
shared.so: shared.o
	ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -shared -fPIC -o shared.so shared.o
shared.o: shared.s
	as -o shared.o shared.s

clean:
	rm -f *.i *.o *.so cheatapp libcheat.s cheatapp.s
