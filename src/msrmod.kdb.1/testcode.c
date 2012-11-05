#include <sys/time.h>
#include <stdlib.h>

extern void start_counters(void);
extern void stop_counters(void);

void execute_test()
{
	struct timeval tv;
	int i;
//	for (i = 1 ; i < 10 ; i++) {
		start_counters();
		gettimeofday(&tv, NULL);
		stop_counters();
//	}
}
