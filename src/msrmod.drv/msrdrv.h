#ifndef _MG_MSRDRV_H
#define _MG_MSRDRV_H

#include <linux/types.h>

#define DEV_MAJOR 223
#define DEV_MINOR 0

enum MsrOperation {
	MSR_NOP = 0,
	MSR_READ = 1,
	MSR_WRITE = 2,
	U32_BITS = 0x7fFFffFF             // ensure enum is 32-bit wide (c) A. Fog you legend
};

struct MsrInOut {
//	MsrOperation op;
	unsigned int op;
	unsigned int ecx;                 // arg register
	union {
		struct {
			unsigned int eax; // low double word
			unsigned int edx; // high double word
		};
		unsigned long long value; // quad word
	};
};

#endif
