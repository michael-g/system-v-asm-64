#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/cdev.h>

#include "msrdrv.h"

MODULE_LICENSE("Dual BSD/GPL");


static int msrdrv_open(struct inode* i, struct file* f)
{
	return 0;
}

static int msrdrv_release(struct inode* i, struct file* f)
{
	return 0;
}

static ssize_t msrdrv_read(struct file *f, char *b, size_t c, loff_t *o) 
{
	return 0;
}

static ssize_t msrdrv_write(struct file *f, const char *b, size_t c, loff_t *o)
{
	return 0;
}

static long msrdrv_ioctl(struct file *f, unsigned int ioctl_num, unsigned long ioctl_param);

dev_t msrdrv_dev;
struct cdev *msrdrv_cdev;

struct file_operations msrdrv_fops = {
	.owner =          THIS_MODULE,
	.read =           msrdrv_read,
	.write =          msrdrv_write,
	.open =           msrdrv_open,
	.release =        msrdrv_release,
	.unlocked_ioctl = msrdrv_ioctl,
	.compat_ioctl =   NULL,
};

static long long read_msr(unsigned int ecx) {
	unsigned int edx = 0, eax = 0;
	unsigned long long result = 0;
	__asm__ __volatile__("rdmsr" : "=a"(eax), "=d"(edx) : "c"(ecx));
	result = eax | (unsigned long long)edx << 0x20;
	printk(KERN_ALERT "Module msrmod: Read 0x%016llx (0x%08x:0x%08x) from MSR 0x%08x\n", result, edx, eax, ecx);
	return result;
}

static void write_msr(int ecx, unsigned int eax, unsigned int edx) {
	printk(KERN_ALERT "Module msrmod: Writing 0x%08x:0x%08x to MSR 0x%04x\n", edx, eax, ecx);
	__asm__ __volatile__("wrmsr" : : "c"(ecx), "a"(eax), "d"(edx));
}

static long msrdrv_ioctl(struct file *f, unsigned int ioctl_num, unsigned long ioctl_param) 
{
	struct MsrInOut *msrops = (struct MsrInOut*)ioctl_param;
	int i;
	for (i = 0 ; i <= ioctl_num ; i++, msrops++) {
		switch (msrops->op) {
		case MSR_READ:
			msrops->value = read_msr(msrops->ecx);
			break;
		case MSR_WRITE:
			write_msr(msrops->ecx, msrops->eax, msrops->edx);
			break;
		case MSR_NOP:
		default:
			printk(KERN_ALERT "Module msrmod: Unknown option %i\n", msrops->op);
			return 1;
		}
	}
	return 0;
}


static int msrmod_init(void)
{
	long int val;
	msrdrv_dev = MKDEV( DEV_MAJOR, DEV_MINOR );
	__asm__ __volatile__("mov %%cr4, %0" : "=r"(val));	// Read %cr4
	val |= 0x100;                                     	// Set RDPMC bit
	__asm__ __volatile__("mov %0, %%cr4" : : "r"(val));	// Write amended value to %cr4
	printk(KERN_ALERT "Module msrmod loaded\n");
	return 0;
}

static void msrmod_exit(void)
{
	long int val;
	__asm__ __volatile__("mov %%cr4, %0" : "=r"(val));
	val &= ~0x100;          // Disable RDPMC
	__asm__ __volatile__("mov %0, %%cr4" : : "r"(val));
	printk(KERN_ALERT "Module msrmod unloaded\n");
}

module_init(msrmod_init);
module_exit(msrmod_exit);

