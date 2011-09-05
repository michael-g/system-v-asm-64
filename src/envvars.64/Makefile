envvars: envvars.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o envvars -lc envvars.o

envvars.o: envvars.s
	as -gstabs -o envvars.o envvars.s

clean:
	rm envvars.o envvars

