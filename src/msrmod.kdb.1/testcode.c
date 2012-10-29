#include <sys/time.h>
#include <stdlib.h>

void executeTest() 
{
	struct timeval tv;
	int i;
	for (i = 1 ; i < 10 ; i++) {
		gettimeofday(&tv, NULL);
	}
}
