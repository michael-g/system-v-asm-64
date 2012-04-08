#include <stdlib.h>
#include <sys/time.h>
#include <stdio.h>

extern struct timeval started_at;

int main(int argc, char *argv[]) 
{
	printf("Started at %llu\n", (long long unsigned int) (started_at.tv_sec));
	return 0;
}
