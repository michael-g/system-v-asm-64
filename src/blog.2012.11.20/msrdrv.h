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

#ifndef _MG_MSRDRV_H
#define _MG_MSRDRV_H

#include <linux/ioctl.h>
#include <linux/types.h>

#define DEV_NAME "msrdrv"
#define DEV_MAJOR 223
#define DEV_MINOR 0

#define MSR_VEC_LIMIT 32

#define IOCTL_MSR_CMDS _IO(DEV_MAJOR, 1)

enum MsrOperation {
	MSR_NOP = 0,
	MSR_READ = 1,
	MSR_WRITE = 2,
	MSR_STOP = 3,
	MSR_RDTSC = 4,
	U32_BITS = 0x7fFFffFF // ensure enum is 32-bit wide
};

struct MsrInOut {
	unsigned int op;
	unsigned int ecx;                 // arg register
	union {
		struct {
			unsigned int eax; // low double word
			unsigned int edx; // high double word
		};
		unsigned long long value; // quad word
	};
}; // msrdrv.h:27:1: warning: packed attribute is unnecessary for ‘MsrInOut’ [-Wpacked]

#endif
