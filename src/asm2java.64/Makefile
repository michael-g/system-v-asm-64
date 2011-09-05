all: HelloWorld.class libhello.so opt3_libhello.so

HelloWorld.class: HelloWorld.java
	javac -cp . HelloWorld.java

libhello.so: HelloWorld.o
	ld -fPIC -shared -o libhello.so HelloWorld.o

HelloWorld.o: HelloWorld.s
	as -gstabs -o HelloWorld.o HelloWorld.s

opt3_libhello.so: HelloWorld.c
	gcc -gstabs -O3 -shared -fPIC -I${JAVA_HOME}/include -I${JAVA_HOME}/include/linux  HelloWorld.c -o opt_libhello.so

clean:
	rm *.o *.class *.so

