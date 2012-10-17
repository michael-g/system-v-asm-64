#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>
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

static inline void wr_msrio(struct MsrInOut *desc, unsigned op, unsigned ecx, unsigned eax, unsigned edx)
{
	desc->op  = op;
	desc->ecx = ecx;
	desc->eax = eax;
	desc->edx = edx;
}

/*
 Writes the MSR_NOP command to 'desc' for example to temporarily skip an 
 MSR-write instruction written previously.
 */
/*
static void wr_msr_nop(struct MsrInOut *desc)
{
        desc->op = MSR_NOP;
}*/

/*
 Writes the MSR_STOP command to 'desc'
 */
static void wr_msr_stop(struct MsrInOut *desc)
{       
        desc->op = MSR_STOP;
}

/*
 Configure the FFC Counters. Writes 'mask' into MSR_PERF_FIXED_CTR_CTRL.EAX. 
 Use mask value 0x222 to enable each of the three i7-2xxx FFCs
 See bit-field image in 3B:18-14/136.
 FFC0: INST_RETIRED.ANY       PMC reg 0x309
 FFC1: CPU_CLK_UNHALTED.CORE  PMC reg 0x30a
 FFC2: CPU_CLK_UNHALTED.REF   PMC reg 0x30b
 */
static void wr_msr_perf_fixed_ctr_ctrl(struct MsrInOut *desc, unsigned int mask)
{
	wr_msrio(desc, MSR_WRITE, 0x38d, mask, 0);
}

/*
 Provides access to the Global Performance Counter Control. Vol 3C:35-19 defines 
 the register bit-fields; see Vol 3B:18-36/p158 for image of bitmask.
 Global PMCs low-DW 7:0
 FFCs high-DW 2:0
 */
static void wr_msr_perf_global_ctrl(struct MsrInOut *desc, unsigned lowDw, unsigned hiDw) 
{
	wr_msrio(desc, MSR_WRITE, 0x38f, lowDw, hiDw);
}
/*
 Writes values to the IA32_PERFEVTSELx register. See 3C:35-6/240,241
 */
static void wr_msr_evt_sel_pmc(struct MsrInOut *desc, unsigned idx, unsigned lowDw)
{
	wr_msrio(desc, MSR_WRITE, 0x186 + idx, lowDw, 0);
}
/*
 Provides the facility to write to the General PMCs. Typical use might be to zero 
 a counter prior to use. See 3C:35-4/p239.
 */
static void wr_msr_pmc(struct MsrInOut *desc, unsigned idx, unsigned lowDw, unsigned hiDw)
{
	wr_msrio(desc, MSR_WRITE, 0xc1 + idx, lowDw, hiDw);
}
static void rd_msr_pmc(struct MsrInOut *desc, unsigned idx)
{
	wr_msrio(desc, MSR_READ, 0xc1 + idx, 0, 0);
}

/*
 Provides the means to write to the FFCs. Typically this could be used to zero 
 a counter.
 */
static void wr_msr_ffc(struct MsrInOut *desc, unsigned idx, unsigned lowDw, unsigned hiDw)
{
	desc->op  = MSR_WRITE;
	desc->ecx = 0x309 + idx;
	desc->eax = lowDw;
	desc->edx = hiDw;
}
static void rd_msr_ffc(struct MsrInOut *desc, unsigned idx)
{
	desc->op  = MSR_READ;
	desc->ecx = 0x309 + idx;
	desc->value = 0;
}


// struct __attribute__((aligned(64))) MyStruct { // etc
int main(int argc, char *argv[])
{
	int i, fd;
	fd = loadDriver();
	struct MsrInOut start_vec[15];
	struct MsrInOut stop_vec[16];

	struct MsrInOut *ptr = (struct MsrInOut*)&start_vec;

	wr_msr_perf_global_ctrl(ptr++, 0, 0);     //  1 Halt all counters
	for (i = 0 ; i < 4 ; i++) 
		wr_msr_pmc(ptr++, i, 0, 0);       //  5 Zero the PMCs
	for (i = 0 ; i < 3 ; i++)
		wr_msr_ffc(ptr++, i, 0, 0);       //  8 Zero the FFCs
	wr_msr_perf_fixed_ctr_ctrl(ptr++, 0x222); //  9 Configure the FFCs
	wr_msr_evt_sel_pmc(ptr++, 0, 0x0041010e); // 10
	wr_msr_evt_sel_pmc(ptr++, 1, 0x0041412e); // 11
	wr_msr_evt_sel_pmc(ptr++, 2, 0x00410f24); // 12
	wr_msr_evt_sel_pmc(ptr++, 3, 0x004101c2); // 13
	wr_msr_perf_global_ctrl(ptr++, 0xf, 0x7); // 14 Start the counters
	wr_msr_stop(ptr++);                       // 15

	ptr = (struct MsrInOut*)&stop_vec;
	wr_msr_perf_global_ctrl(ptr++, 0, 0);     //  1 Halt all counters
	for (i = 0 ; i < 4 ; i++) 
		rd_msr_pmc(ptr++, i);             //  5 Read the PMCs
	for (i = 0 ; i < 3 ; i++)
		rd_msr_ffc(ptr++, i);             //  8 Read the FFCs
	for (i = 0 ; i < 4 ; i++) 
		wr_msr_pmc(ptr++, i, 0, 0);       // 12 Zero the PMCs
	for (i = 0 ; i < 3 ; i++)
		wr_msr_ffc(ptr++, i, 0, 0);       // 15 Zero the FFCs
	wr_msr_stop(ptr++);                       // 16
	
	ioctl(fd, IOCTL_MSR_CMDS, (long long)&start_vec);
//	puts("Some more uops burned up here...");

	ioctl(fd, IOCTL_MSR_CMDS, (long long)&stop_vec);

	printf("%8llu UOPS_ISSUED.ANY   0x0e:0x01\n", stop_vec[1].value);
	printf("%8llu L3_LAT_CACHE.MISS 0x2e:0x41\n", stop_vec[2].value);
	printf("%8llu L2_L1D Miss       0x24:0x0f\n", stop_vec[3].value);
	printf("%8llu UOPS_RETIRED.ANY  0xc2:0x01\n", stop_vec[4].value);
	printf("%8llu INST_RETIRED.ANY\n",            stop_vec[5].value);
	printf("%8llu CPU_CLK_UNHALTED.CORE\n",       stop_vec[6].value);
	printf("%8llu CPU_CLK_UNHALTED.REF\n",        stop_vec[7].value);

	closeDriver(fd);
	return 0;
}

