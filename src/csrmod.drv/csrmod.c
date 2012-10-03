#include <linux/init.h>
#include <linux/module.h>

MODULE_LICENSE("Dual BSD/GPL");

static int csrmod_init(void)
{
	long int val;
	__asm__ __volatile__("mov %%cr4, %0" : "=r"(val));
	val |= 0x100;           // Enable RDPMC
	__asm__ __volatile__("mov %0, %%cr4" : : "r"(val));
	printk(KERN_ALERT "Module csrmod loaded\n");
	return 0;
}

static void csrmod_exit(void)
{
	long int val;
	__asm__ __volatile__("mov %%cr4, %0" : "=r"(val));
	val &= ~0x100;          // Disable RDPMC
	__asm__ __volatile__("mov %0, %%cr4" : : "r"(val));
	printk(KERN_ALERT "Module csrmod unloaded\n");
}

module_init(csrmod_init);
module_exit(csrmod_exit);

