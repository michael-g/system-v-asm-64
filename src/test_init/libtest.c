#include <stdlib.h>
#include <sys/time.h>

struct timeval started_at;

void __attribute ((constructor)) my_arse(void) 
{
	gettimeofday(&started_at, NULL);
	
}
