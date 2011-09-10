all: HelloArgs.h libhello.so 
	# Now execute:
	# $ java -Djava.library.path=$$(pwd) -cp . HelloArgs

HelloArgs.h: HelloArgs.class 
	javah -classpath . HelloArgs

HelloArgs.class: HelloArgs.java
	javac -cp . HelloArgs.java

#
# Note the use of the dynamic linker
#	ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -fPIC -shared -o libhello.so hello.o -lc
#
libhello.so: hello.o
	ld -fPIC -shared -o libhello.so hello.o -lc

hello.o: HelloArgs.s
	as -gstabs -o hello.o HelloArgs.s

gensrc:
	gcc -shared -fPIC -I${JAVA_HOME}/include -I${JAVA_HOME}/include/linux -S HelloArgs.c

clean:
	rm *.o *.h *.class *.so 

