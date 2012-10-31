extern void start_baseline(void);
extern void stop_baseline(void);

void execute_baseline(int times)
{
	int i;
	for (i = 0 ; i < times ; i++) {
		start_baseline();
		stop_baseline();
	}
}

