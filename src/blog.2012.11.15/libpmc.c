/*
 (c) Michael Guyver, 2012, all rights reserved. Permission to use, copy, modify and distribute the 
 software is hereby granted for educational use which is non-commercial in nature, provided that 
 this copyright  notice and following two paragraphs are included in all copies, modifications and 
 distributions.

 THIS SOFTWARE AND DOCUMENTATION IS PROVIDED "AS IS," AND NO REPRESENTATIONS OR WARRANTIES ARE 
 MADE, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO, WARRANTIES OF MERCHANTABILITY OR 
 FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE SOFTWARE OR DOCUMENTATION WILL NOT 
 INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.

 COPYRIGHT HOLDERS WILL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL OR CONSEQUENTIAL DAMAGES 
 ARISING OUT OF ANY USE OF THE SOFTWARE OR DOCUMENTATION.
*/
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <dlfcn.h>

#include "msrdrv.h"
#define KXVER 3
#include "k.h"

#define FFC_COUNT 3
#define PMC_COUNT 4

extern void execute_baseline(int times, void (start_counters)(void), void (stop_counters)(void));

static int fd;
unsigned long long *pmc_fixed;
unsigned long long *ffc_fixed;
static struct MsrInOut *pmc_reset;
static struct MsrInOut *pmc_cfg;
static struct MsrInOut *pmc_read;

static void loadDriver()
{
	fd = open("/dev/" DEV_NAME, O_RDWR);
	if (fd == -1) {
		krr("Failed to open /dev/" DEV_NAME);
	}
	return;
}

static void closeDriver() 
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

/*
static void run_baseline(unsigned long long *pmc_baseline, unsigned long long *ffc_baseline, int count) 
{
	int i;
	for (i = 0 ; i < count ; i++) {
		ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_reset);
		ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_cfg);
		ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_read);
	}
}*/

static void record_reset()
{
	int i;
	struct MsrInOut *ptr = pmc_reset;
	msr_wr_perf_global_ctrl(ptr++, 0, 0);       // 1 Halt all counters
	for (i = 0 ; i < PMC_COUNT ; i++) 
		msr_wr_pmc(ptr++, i, 0, 0);         // 5 Zero the PMCs
	for (i = 0 ; i < FFC_COUNT ; i++)
		msr_wr_ffc(ptr++, i, 0, 0);         // 8 Zero the FFCs
	msr_wr_stop(ptr++);                         // 9
} 

static void record_read()
{
	int i;
	struct MsrInOut *ptr = pmc_read;
	msr_wr_perf_global_ctrl(ptr++, 0, 0);       // 1 Halt all counters
	for (i = 0 ; i < PMC_COUNT ; i++) 
		msr_rd_pmc(ptr++, i);               // 5 Read the PMCs
	for (i = 0 ; i < FFC_COUNT ; i++)
		msr_rd_ffc(ptr++, i);               // 8 Read the FFCs
	msr_wr_stop(ptr++);                         // 9
}

void start_counters()
{
	ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_cfg);
	return;
}

void stop_counters()
{
	ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_read);
	return;
}

void start_baseline()
{
	ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_cfg);
	return;
}

void stop_baseline()
{
	ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_read);
	return;
}


static K run_test(void (*execute_test)(void(s1)(void),void(s2)(void)), int testCount) 
{
	int i;
	K result, kffc[3], kpmc[4];

	for (i = 0 ; i < PMC_COUNT ; i++) 
		pmc_fixed[i] = 0;
	for (i = 0 ; i < FFC_COUNT ; i++) 
		ffc_fixed[i] = 0;

	ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_reset);
	execute_baseline(testCount, &start_baseline, &stop_baseline);
	pmc_fixed[0] = pmc_read[1].value / testCount;
	pmc_fixed[1] = pmc_read[2].value / testCount;
	pmc_fixed[2] = pmc_read[3].value / testCount;
	pmc_fixed[3] = pmc_read[4].value / testCount;
	ffc_fixed[0] = pmc_read[5].value / testCount;
	ffc_fixed[1] = pmc_read[6].value / testCount;
	ffc_fixed[2] = pmc_read[7].value / testCount;

	for (i = 0 ; i < PMC_COUNT ; i++) 
		kpmc[i] = ktn(KJ, testCount);
	
	for (i = 0 ; i < FFC_COUNT ; i++) 
		kffc[i] = ktn(KJ, testCount);
	
	for (i = 1 ; i < 1 + PMC_COUNT + FFC_COUNT ; i++)
		pmc_read[i].value = 0;
	
	for (i = 0 ; i < testCount ; i++) {
		ioctl(fd, IOCTL_MSR_CMDS, (long long)pmc_reset);
		execute_test(&start_counters, &stop_counters);
		kJ(kpmc[0])[i] = pmc_read[1].value - pmc_fixed[0];
		kJ(kpmc[1])[i] = pmc_read[2].value - pmc_fixed[1];
		kJ(kpmc[2])[i] = pmc_read[3].value - pmc_fixed[2];
		kJ(kpmc[3])[i] = pmc_read[4].value - pmc_fixed[3];
		kJ(kffc[0])[i] = pmc_read[5].value - ffc_fixed[0];
		kJ(kffc[1])[i] = pmc_read[6].value - ffc_fixed[1];
		kJ(kffc[2])[i] = pmc_read[7].value - ffc_fixed[2];
	}
	result = knk(7, kffc[0], kffc[1], kffc[2], kpmc[0], kpmc[1], kpmc[2], kpmc[3]);
	return result;
}

K runtest(K opv, K ecxv, K eaxv, K edxv, K testCount)
{
	struct MsrInOut s_pmc_reset[9];
	struct MsrInOut s_pmc_read[9];
	unsigned long long s_ffc_fixed[FFC_COUNT];
	unsigned long long s_pmc_fixed[PMC_COUNT]; 
	struct MsrInOut *ptr;
	int i;
	long long count;
	void *handle;
	char *error;
	K result;
	void (*execute_test)(void (s1)(void), void(s2)(void));

	// dynamically load the test library
	handle = dlopen("libtest.so", RTLD_NOW);
	//handle = dlopen("libtest.so", RTLD_LAZY);
	if (!handle) {
		krr(dlerror()); // signal exception to kdb+
		return (K)0;
	}
	execute_test = dlsym(handle, "execute_test");
	if ((error = dlerror()) != NULL) {
		krr("While locating symbof 'execute_test'");
		return (K)0;
	}


	// zero the fixed-cost accumulators
	for (i = 0 ; i < PMC_COUNT ; i++)
		s_pmc_fixed[i] = 0;
	for (i = 0 ; i < FFC_COUNT ; i++)
		s_ffc_fixed[i] = 0;

	// set the global (static) pointers
	ffc_fixed = s_ffc_fixed;
	pmc_fixed = s_pmc_fixed;
	pmc_reset = s_pmc_reset;
	pmc_read = s_pmc_read;
	ptr = pmc_cfg = (struct MsrInOut*)malloc((opv->n + 1) * sizeof(struct MsrInOut));

	if (pmc_cfg == NULL) {
		orr("malloc");
		return (K)0;
	}
	
	record_reset();
	record_read();

	// record the PMC instructions to memory
	count = opv->n;
	for (i = 0 ; i < count ; i++) {
		wr_msrio(ptr++, kI(opv)[i], kI(ecxv)[i], kI(eaxv)[i], kI(edxv)[i]);
	}
	msr_wr_stop(ptr++);
	
	loadDriver();
	if (fd == -1) {
		return (K)0;
	}
	result = run_test(execute_test, testCount->i);
	
	// disable and zero the PMC MSRs
	ioctl(fd, IOCTL_MSR_CMDS, (long long)s_pmc_reset);

	// return the dynamically allocated memory
	free(pmc_cfg);	
	// close the dyn-lib function handle
	dlclose(handle);
	// close the MSR driver
	closeDriver(fd);

	return result;
}

