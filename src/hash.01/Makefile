SOURCES=main.c hashtable.c
OBJECTS=$(SOURCES:.c=.o)
CFLAGS=-I. -Wall -std=c99 -O2
EXEC=main

$(EXEC): $(OBJECTS)
	$(CC) $(OBJECTS) -o $(EXEC)

hashtable.o: hashtable.h

main.o: hashtable.h

clean:
	$(RM) -f *.o *.i *.s $(OUTPUT)
