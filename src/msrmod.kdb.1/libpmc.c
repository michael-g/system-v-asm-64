#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>

#include "msrdrv.h"
#include "msrenum.h"
#define KXVER 3
#include "k.h"

static int loadDriver()
{
	int fd = open("/dev/" DEV_NAME, O_RDWR);
	if (fd == -1) {
		krr("Failed to open /dev/" DEV_NAME);
	}
	return fd;
}

static void closeDriver(int fd) 
{
	int e = close(fd);
	if (e == -1) {
		krr("Failed to close fd");
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

static void run_baseline(int fd, struct MsrInOut *pmc_reset, struct MsrInOut *pmc_cfg, struct MsrInOut *pmc_read, unsigned long long *pmc_baseline, unsigned long long *ffc_baseline, int count) 
{
	int i;
	for (i = 0 ; i < count ; i++) {
		ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_reset);
		ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_cfg);
		ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_read);
	}
	pmc_baseline[0] = pmc_read[1].value / count;
	pmc_baseline[1] = pmc_read[2].value / count;
	pmc_baseline[2] = pmc_read[3].value / count;
	pmc_baseline[3] = pmc_read[4].value / count;
	ffc_baseline[0] = pmc_read[5].value / count;
	ffc_baseline[1] = pmc_read[6].value / count;
	ffc_baseline[2] = pmc_read[7].value / count;
}

static void record_reset(struct MsrInOut *ptr)
{
	int i;
	msr_wr_perf_global_ctrl(ptr++, 0, 0);       // 1 Halt all counters
	for (i = 0 ; i < 4 ; i++) 
		msr_wr_pmc(ptr++, i, 0, 0);         // 5 Zero the PMCs
	for (i = 0 ; i < 3 ; i++)
		msr_wr_ffc(ptr++, i, 0, 0);         // 8 Zero the FFCs
	msr_wr_stop(ptr++);                         // 9
} 

static void record_read(struct MsrInOut *ptr)
{
	int i;
	msr_wr_perf_global_ctrl(ptr++, 0, 0);       // 1 Halt all counters
	for (i = 0 ; i < 4 ; i++) 
		msr_rd_pmc(ptr++, i);               // 5 Read the PMCs
	for (i = 0 ; i < 3 ; i++)
		msr_rd_ffc(ptr++, i);               // 8 Read the FFCs
	msr_wr_stop(ptr++);                         // 9
}

extern void executeTest();

static K execute_test(int fd, struct MsrInOut *pmc_reset, struct MsrInOut *pmc_cfg, struct MsrInOut *pmc_read, int testCount) 
{
	int i;
	K result, kffc[3], kpmc[4];;
	unsigned long long pmc_fixed[4], ffc_fixed[3];

	run_baseline(fd, pmc_reset, pmc_cfg, pmc_read, pmc_fixed, ffc_fixed, testCount);
	for (i = 0 ; i < 3 ; i++) 
		kffc[i] = ktn(KI, testCount);
	for (i = 0 ; i < 4 ; i++) 
		kpmc[i] = ktn(KI, testCount);

	for (i = 0 ; i < testCount ; i++) {
		ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_reset);
		ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_cfg);
		executeTest();
		ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_read);
		kI(kpmc[0])[i] = pmc_read[1].value - pmc_fixed[0];
		kI(kpmc[1])[i] = pmc_read[2].value - pmc_fixed[1];
		kI(kpmc[2])[i] = pmc_read[3].value - pmc_fixed[2];
		kI(kpmc[3])[i] = pmc_read[4].value - pmc_fixed[3];
		kI(kffc[0])[i] = pmc_read[5].value - pmc_fixed[0];
		kI(kffc[1])[i] = pmc_read[6].value - pmc_fixed[1];
		kI(kffc[2])[i] = pmc_read[7].value - pmc_fixed[2];
	}
	result = knk(7, kffc[0], kffc[1], kffc[2], kpmc[0], kpmc[1], kpmc[2], kpmc[3]);
	return result;
}

K runtest(K opv, K ecxv, K eaxv, K edxv, K testCount)
{
	struct MsrInOut pmc_reset[9];
	struct MsrInOut pmc_read[9];
	struct MsrInOut *dyn_script, *ptr;
	int i, fd;
	long long count;
	K result;

	dyn_script = ptr = (struct MsrInOut*)malloc((opv->n + 1) * sizeof(struct MsrInOut));
	if (ptr == NULL) {
		orr("malloc");
		return (K)0;
	}

	record_reset(pmc_reset);
	record_read(pmc_read);

	count = opv->n;
	for (i = 0 ; i < count ; i++) {
		wr_msrio(ptr++, kI(opv)[i], kI(ecxv)[i], kI(eaxv)[i], kI(edxv)[i]);
	}
	msr_wr_stop(ptr++);
	
	fd = loadDriver();
	if (fd == -1) {
		return (K)0;
	}
	result = execute_test(fd, pmc_reset, dyn_script, pmc_read, testCount->i);
	
	ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_reset);
	free(dyn_script);	
	closeDriver(fd);

	return result;
}

