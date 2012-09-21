#include <stdlib.h>

static __thread void *tlRwVar;

static const int localRoVar = 0x12345678;
const int globalRoVar = 0xCAFEBABE;
static const int *addOfGlobalRoVar = &globalRoVar;

static int localRwVar = 0x55378008;
int globalRwVar = 0xDEADBEEF;

static int localBssVar[32];
int globalBssVar[32];

void globalSharedFunc(void *addrs[]) 
{
	tlRwVar = (void *)&addrs;
	addrs[0] = (void *)&localRoVar;
	addrs[1] = (void *)&globalRoVar;
	addrs[2] = (void *)&localRwVar;
	addrs[3] = (void *)&globalRwVar;
	addrs[4] = (void *)&localBssVar;
	addrs[5] = (void *)&globalBssVar;
	addrs[6] = (void *)addOfGlobalRoVar;
	addrs[7] = (void *)&tlRwVar;
}
