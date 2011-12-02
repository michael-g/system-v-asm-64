all: fpmath.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o fpmath -lc fpmath.o

fpmath.o: fpmath.s
	as -gstabs -o fpmath.o fpmath.s

clean:
	@$(RM) fpmath.o fpmath

