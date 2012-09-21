#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#define AZ(m, e) if ((e) < 0) {    \
	perror(m);               \
	return 1;                  \
}

int
main(void)
{
	char *path = "/dev/cpu/1/msr\0";
	int e, fd;
	unsigned long long freq;
	fd = open(path, O_RDONLY);
	if (fd < 0) {
		perror("Failed to open MSR");
		printf("Failed to open %s\n", path);
		return -1;
	}
	printf("Successfully opened %s\n", path);
	e = pread(fd, (void *)&freq, 0x8, 0xCE);
	AZ("While reading 0xCE", e);

	printf("Value returned for pread at offset 0xCE is %Lx\n", freq);
	printf("Current frequency is %hhd\n", (int)((freq >> 8) & 0xFF));
	
	e = pread(fd, (void *)&freq, 0x08, 0xE7);
	AZ("While reading IA32_MPERF",e);
	printf("IA32_MPERF (0xE7) is %Ld\n", (unsigned long long)freq);	
	
	e = pread(fd, (void*)&freq, 0x08, 0xE8);
	AZ("While reading IA32_MPERF",e);
	printf("IA32_MPERF (0xE8) is %Ld\n", (unsigned long long)freq);	
	
	e = close(fd);
	if (e < 0) {
		perror("While closing FD");
	}
	return e;
}
