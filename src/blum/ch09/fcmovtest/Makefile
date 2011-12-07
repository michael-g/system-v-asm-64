all: fcmovtest.o
	ld --dynamic-linker /lib/ld-linux-x86-64.so.2 -o fcmovtest -lc fcmovtest.o

fcmovtest.o: fcmovtest.s
	as -gstabs -o fcmovtest.o fcmovtest.s

clean:
	@$(RM) fcmovtest *.o

