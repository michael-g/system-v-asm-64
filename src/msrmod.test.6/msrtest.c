#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>

#include "msrdrv.h"
#include "msrenum.h"

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
 Writes the MSR_STOP command to 'desc'
 */
static void msr_wr_stop(struct MsrInOut *desc)
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
static void msr_wr_perf_fixed_ctr_ctrl(struct MsrInOut *desc, unsigned int mask)
{
	wr_msrio(desc, MSR_WRITE, 0x38d, mask, 0);
}

/*
 Provides access to the Global Performance Counter Control. Vol 3C:35-19 defines 
 the register bit-fields; see Vol 3B:18-36/p158 for image of bitmask.
 Global PMCs low-DW 7:0
 FFCs high-DW 2:0
 */
static void msr_wr_perf_global_ctrl(struct MsrInOut *desc, unsigned lowDw, unsigned hiDw) 
{
	wr_msrio(desc, MSR_WRITE, 0x38f, lowDw, hiDw);
}
/*
 Writes values to the IA32_PERFEVTSELx register. See 3C:35-6/240,241
 */
static void msr_wr_evt_sel_pmc(struct MsrInOut *desc, unsigned idx, unsigned lowDw)
{
	wr_msrio(desc, MSR_WRITE, 0x186 + idx, lowDw, 0);
}
/*
 Provides the facility to write to the General PMCs. Typical use might be to zero 
 a counter prior to use. See 3C:35-4/p239.
 */
static void msr_wr_pmc(struct MsrInOut *desc, unsigned idx, unsigned lowDw, unsigned hiDw)
{
	wr_msrio(desc, MSR_WRITE, 0xc1 + idx, lowDw, hiDw);
}
static void msr_rd_pmc(struct MsrInOut *desc, unsigned idx)
{
	wr_msrio(desc, MSR_READ, 0xc1 + idx, 0, 0);
}

/*
 Provides the means to write to the FFCs. Typically this could be used to zero 
 a counter.
 */
static void msr_wr_ffc(struct MsrInOut *desc, unsigned idx, unsigned lowDw, unsigned hiDw)
{
	desc->op  = MSR_WRITE;
	desc->ecx = 0x309 + idx;
	desc->eax = lowDw;
	desc->edx = hiDw;
}
static void msr_rd_ffc(struct MsrInOut *desc, unsigned idx)
{
	desc->op  = MSR_READ;
	desc->ecx = 0x309 + idx;
	desc->value = 0;
}

static void run_baseline(int fd, struct MsrInOut *pmc_cfg, struct MsrInOut *pmc_read, long long unsigned int *baseline, int baseLoops) 
{
	int i;
	for (i = 0 ; i < baseLoops ; i++) {
		ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_cfg);
		ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_read);
	}
	baseline[0] = pmc_read[1].value / baseLoops;
	baseline[1] = pmc_read[2].value / baseLoops;
	baseline[2] = pmc_read[3].value / baseLoops;
	baseline[3] = pmc_read[4].value / baseLoops;
	baseline[4] = pmc_read[5].value / baseLoops;
	baseline[5] = pmc_read[6].value / baseLoops;
	baseline[6] = pmc_read[7].value / baseLoops;
}

static unsigned long long calc_avg(unsigned long long fixedLatency, unsigned long long value, unsigned count) 
{
	return (value / count) - fixedLatency;
}

int main(void)
{
	int i, fd, baseLoops;
	struct MsrInOut pmc_reset[9];
	struct MsrInOut pmc_read[9];
	struct MsrInOut pmc_cfg_0[7];
	//struct MsrInOut pmc_cfg_1[7];
	//struct MsrInOut pmc_cfg_2[7];
	struct MsrInOut *ptr;
	baseLoops = 32;

	unsigned long long baseline[7]; // 4 PMCs and 3 FFCs

	ptr = (struct MsrInOut*)&pmc_reset;
	msr_wr_perf_global_ctrl(ptr++, 0, 0);                                      // 1 Halt all counters
	for (i = 0 ; i < 4 ; i++) 
		msr_wr_pmc(ptr++, i, 0, 0);                                        // 5 Zero the PMCs
	for (i = 0 ; i < 3 ; i++)
		msr_wr_ffc(ptr++, i, 0, 0);                                        // 8 Zero the FFCs
	msr_wr_stop(ptr++);                                                        // 9

	ptr = (struct MsrInOut*)&pmc_read;
	msr_wr_perf_global_ctrl(ptr++, 0, 0);                                      // 1 Halt all counters
	for (i = 0 ; i < 4 ; i++) 
		msr_rd_pmc(ptr++, i);                                              // 5 Read the PMCs
	for (i = 0 ; i < 3 ; i++)
		msr_rd_ffc(ptr++, i);                                              // 8 Read the FFCs
	msr_wr_stop(ptr++);                                                        // 9
	
	ptr = (struct MsrInOut*)&pmc_cfg_0;
	msr_wr_perf_fixed_ctr_ctrl(ptr++, 0x222);                                  // 1 Configure the FFCs
	msr_wr_evt_sel_pmc(ptr++, 0, FLAG_EN | FLAG_USR | UOPS_RETIRED_ALL); 
	msr_wr_evt_sel_pmc(ptr++, 1, FLAG_EN | FLAG_USR | UOPS_RETIRED_ALL | CMASK_1 | FLAG_INV); 
	msr_wr_evt_sel_pmc(ptr++, 2, FLAG_EN | FLAG_USR | L2_RQSTS_ALL_DEMAND_DATA_RD | L2_RQSTS_RFO_HITS | L2_RQSTS_RFO_MISS); 
	msr_wr_evt_sel_pmc(ptr++, 3, FLAG_EN | FLAG_USR | LONGEST_LAT_CACHE_MISS | LONGEST_LAT_CACHE_REFERENCE); 

	msr_wr_perf_global_ctrl(ptr++, 0xf, 0x7);                                  // 6 Start the counters
	msr_wr_stop(ptr++);                                                        // 7

	fd = loadDriver();

	ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_reset);
	run_baseline(fd, pmc_cfg_0, pmc_read, baseline, baseLoops);

	puts("Baseline measurement latency overheads:");
	printf("UOPS_RETIRED.ALL         %8llu\n", baseline[0]);
	printf("stalled UOPS_RETIRED.ALL %8llu\n", baseline[1]);
	printf("L1 Cache Miss            %8llu\n", baseline[2]);
	printf("L2 Cache Miss            %8llu\n", baseline[3]);
	printf("INST_RETIRED.ANY         %8llu\n", baseline[4]);
	printf("CPU_CLK_UNHALTED.CORE    %8llu\n", baseline[5]);
	printf("CPU_CLK_UNHALTED.REF     %8llu\n", baseline[6]);

	printf("             %10s %10s %10s %10s %10s %10s %10s\n", "inst_rtd", "clk_core", "clk_ref", "uops_rtd", "0-uops_rtd", "L1_miss", "L2_miss");
	for (i = 0 ; i < baseLoops ; i++) {
		ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_reset);
		ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_cfg_0);
		printf("Result [%2d]: ", i);
		ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_read);
		printf("%10llu %10llu %10llu %10llu %10llu %10llu %10llu\n", 
			pmc_read[5].value - baseline[4],
			pmc_read[6].value - baseline[5],
			pmc_read[7].value - baseline[6],
			pmc_read[1].value - baseline[0], 
			pmc_read[2].value - baseline[1],
			pmc_read[3].value - baseline[2],
			pmc_read[4].value - baseline[3]);
	}
	
	closeDriver(fd);

	return 0;
}

