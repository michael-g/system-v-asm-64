all: getstatus.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o getstatus -lc getstatus.o

getstatus.o: getstatus.s
	as -gstabs -o getstatus.o getstatus.s

clean:
	@$(RM) getstatus.o getstatus
