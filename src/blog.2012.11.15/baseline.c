
void execute_baseline(int times, void (start_baseline)(void), void (stop_baseline)(void))
{
	int i;
	for (i = 0 ; i < times ; i++) {
		start_baseline();
		stop_baseline();
	}
}

