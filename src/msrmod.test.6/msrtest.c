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


int main(void)
{
	int i, fd, baseLoops;
	struct MsrInOut pmc_reset[9];
	struct MsrInOut pmc_cfg[7];
	struct MsrInOut pmc_read[9];
	struct MsrInOut *ptr;
	unsigned long long pmc0, pmc1, pmc2, pmc3, ffc0, ffc1, ffc2;
	baseLoops = 32;
	pmc0 = pmc1 = pmc2 = pmc3 = ffc0 = ffc1 = ffc2 = 0;

	ptr = (struct MsrInOut*)&pmc_reset;

	wr_msr_perf_global_ctrl(ptr++, 0, 0);                                      // 1 Halt all counters
	for (i = 0 ; i < 4 ; i++) 
		wr_msr_pmc(ptr++, i, 0, 0);                                        // 5 Zero the PMCs
	for (i = 0 ; i < 3 ; i++)
		wr_msr_ffc(ptr++, i, 0, 0);                                        // 8 Zero the FFCs
	wr_msr_stop(ptr++);                                                        // 9

	ptr = (struct MsrInOut*)&pmc_cfg;
	wr_msr_perf_fixed_ctr_ctrl(ptr++, 0x222);                                  // 1 Configure the FFCs
	wr_msr_evt_sel_pmc(ptr++, 0, FLAG_EN | FLAG_USR | UOPS_ISSUED_ANY);        // 2
	wr_msr_evt_sel_pmc(ptr++, 1, FLAG_EN | FLAG_USR | LONGEST_LAT_CACHE_MISS); // 3
	wr_msr_evt_sel_pmc(ptr++, 2, FLAG_EN | FLAG_USR | L2_RQSTS_RFO_MISS);      // 4
	wr_msr_evt_sel_pmc(ptr++, 3, FLAG_EN | FLAG_USR | UOPS_RETIRED_ALL);       // 5
	wr_msr_perf_global_ctrl(ptr++, 0xf, 0x7);                                  // 6 Start the counters
	wr_msr_stop(ptr++);                                                        // 7

	ptr = (struct MsrInOut*)&pmc_read;
	wr_msr_perf_global_ctrl(ptr++, 0, 0);                                      // 1 Halt all counters
	for (i = 0 ; i < 4 ; i++) 
		rd_msr_pmc(ptr++, i);                                              // 5 Read the PMCs
	for (i = 0 ; i < 3 ; i++)
		rd_msr_ffc(ptr++, i);                                              // 8 Read the FFCs
	wr_msr_stop(ptr++);                                                        // 9
	
	fd = loadDriver();

	for (i = 0 ; i < baseLoops ; i++) {
		ioctl(fd, IOCTL_MSR_CMDS, (long long)&pmc_cfg);
		ioctl(fd, IOCTL_MSR_CMDS, (long long)&pmc_read);
		pmc0 += pmc_read[1].value;
		pmc1 += pmc_read[2].value;
		pmc2 += pmc_read[3].value;
		pmc3 += pmc_read[4].value;
		ffc0 += pmc_read[5].value;
		ffc1 += pmc_read[6].value;
		ffc2 += pmc_read[7].value;
	}

	printf("%8llu UOPS_ISSUED.ANY\n", pmc0 / baseLoops);
	printf("%8llu LONGEST_LAT_CACHE.MISS\n", pmc1 / baseLoops);
	printf("%8llu L2_RQSTS.RFO_MISS\n", pmc2 / baseLoops);
	printf("%8llu UOPS_RETIRED.ALL\n", pmc3 / baseLoops);
	printf("%8llu INST_RETIRED.ANY\n", ffc0 / baseLoops);
	printf("%8llu CPU_CLK_UNHALTED.CORE\n", ffc1 / baseLoops);
	printf("%8llu CPU_CLK_UNHALTED.REF\n", ffc2 / baseLoops);

	closeDriver(fd);

	return 0;
}

