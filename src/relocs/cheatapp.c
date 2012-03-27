
extern int globalRoVar;
extern int globalRwVar;
extern int globalBssVar;

extern void globalSharedFunc(void *arr[]);

int main(int argc, char *argv[]) 
{
	void *addresses[9];
	globalSharedFunc((void **)&addresses);
	addresses[6] = &globalRoVar;
	addresses[7] = &globalRwVar;
	addresses[8] = &globalBssVar;
	globalSharedFunc((void **)&addresses);
	return 0;
}
