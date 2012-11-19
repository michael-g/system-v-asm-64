#include <sys/time.h>
#include <stdlib.h>

void execute_test(void(*start_counters)(void), void(*stop_counters)(void))
{
	struct timeval tv;
	start_counters();
	gettimeofday(&tv, NULL);
	stop_counters();
}
