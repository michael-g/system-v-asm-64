#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <errno.h>

#include "msrdrv.h"

static int loadDriver()
{
	int fd = open("/dev/" DEV_NAME, O_RDWR);
	if (fd == -1) {
		perror("Failed to open /dev/" DEV_NAME);
	}
	return fd;
}

static void closeDriver(int fd) 
{
	int e = close(fd);
	if (e == -1) {
		perror("Failed to close fd");
	}
}

// struct __attribute__((aligned(64))) MyStruct { // etc
int main(int argc, char *argv[])
{
	int fd = loadDriver();
	struct MsrInOut start_vec[5];
	struct MsrInOut stop_vec[4];

	start_vec[0].op = MSR_WRITE;
	start_vec[0].ecx = 0x38d; // MSR_PERF_FIXED_CTR_CTRL
	start_vec[0].eax = 0x222; // Enable all 3 i7 FFnCs
	start_vec[0].edx = 0x00;  // 
	
	start_vec[1].op = MSR_WRITE;
	start_vec[1].ecx = 0x38f; // MSR_PERF_GLOBAL_CTRL
	start_vec[1].eax = 0x0f;  // Enable all 4 PMCs;
	start_vec[1].edx = 0x07;  // Enable all 3 FFnCs

	start_vec[2].op = MSR_WRITE;
	start_vec[2].ecx = 0x186; // IA32_PERFEVTSEL0 (0x186..0x186+n)
	start_vec[2].eax = 0xc2 | (0x01 << 8) | (1 << 16) | (1 << 22);
	                          // uops retired (0xc2) | mask (0x01 << 8)
	start_vec[2].edx = 0x00;  

	start_vec[3].op = MSR_WRITE;
	start_vec[3].ecx = 0xc1;  // IA32_PMC0 (0xc1..0xc1+n)
	start_vec[3].value = 0;   // Zero the counter

	start_vec[4].op = MSR_STOP;

	stop_vec[0].op = MSR_WRITE;
	stop_vec[0].ecx = 0x38d; // MSR_PERF_FIXED_CTR_CTRL
	stop_vec[0].value = 0;   // Disable all three i7 FFnCtrs
	
	stop_vec[1].op = MSR_WRITE;
	stop_vec[1].ecx = 0x38f; // MSR_PERF_GLOBAL_CTRL
	stop_vec[1].value = 0;   // Disable all three i7 FFnCtrs

	stop_vec[2].op = MSR_READ;
	stop_vec[2].ecx = 0xc1; // IA32_PERFEVTSEL0 (0x186..0x186+n)
	stop_vec[2].value = 0; 

	stop_vec[3].op = MSR_STOP;

	ioctl(fd, IOCTL_MSR_CMDS, (long long)&start_vec);
	puts("Some more uops burned up here...");
	ioctl(fd, IOCTL_MSR_CMDS, (long long)&stop_vec);
	printf("Micro-ops retired %llu\n", stop_vec[2].value);
	closeDriver(fd);
	return 0;
}

