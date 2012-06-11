#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <stdint.h>

void printSelfMaps() 
{
	FILE *fpMaps;
	FILE *fpMem;
	uintptr_t startAddr;
	uintptr_t endAddr;
	unsigned int offset;
	unsigned int inode;
	int res;
	#define BUFF_SZ 256
	char binPath[BUFF_SZ];
	char outPath[BUFF_SZ];
	char perms[5];

	fpMaps = fopen("/proc/self/maps", "r");
	if (fpMaps == NULL) {
		fprintf(stderr, "Failed to open /proc/self/maps: %d\n", errno);
		exit(1);
	}

	do {
		res = fscanf(fpMaps, "%lx-%lx %s %x %*s %x%*[ ]%[^\n]", &startAddr, &endAddr, perms, &offset, &inode, binPath);
		if (res) {
			printf("%lx-%lx %s %7x %7x %s\n", startAddr, endAddr, perms, offset, inode, binPath);
			sprintf(outPath, "./%lx_%lx_%s_%x", startAddr, endAddr, perms, offset);
			fpMem = fopen(outPath, "w");
			if (fpMem == NULL) {
				fprintf(stderr, "Failed to open file %s for writing\n", outPath);
				exit(1);
			}
			fwrite((void*)startAddr, 0x1000, (endAddr-startAddr)>>0xC, fpMem);
			fclose(fpMem);
			offset = fgetc(fpMaps);
			if (offset == EOF) {
				break;
			}
			binPath[0] = '\0';
		}
		
	} 
	while (res);
	return;
}

/*
00400000-0040d000 r-xp 00000000 08:01 1048598                            /bin/cat
0060d000-0060e000 r--p 0000d000 08:01 1048598                            /bin/cat
0060e000-0060f000 rw-p 0000e000 08:01 1048598                            /bin/cat
025f8000-02619000 rw-p 00000000 00:00 0                                  [heap]
7f62ff0ed000-7f62ff267000 r-xp 00000000 08:01 262282                     /lib/libc-2.11.1.so
7f62ff267000-7f62ff466000 ---p 0017a000 08:01 262282                     /lib/libc-2.11.1.so
7f62ff466000-7f62ff46a000 r--p 00179000 08:01 262282                     /lib/libc-2.11.1.so
7f62ff46a000-7f62ff46b000 rw-p 0017d000 08:01 262282                     /lib/libc-2.11.1.so
7f62ff46b000-7f62ff470000 rw-p 00000000 00:00 0 
7f62ff470000-7f62ff490000 r-xp 00000000 08:01 262258                     /lib/ld-2.11.1.so
7f62ff516000-7f62ff555000 r--p 00000000 08:01 400009                     /usr/lib/locale/en_GB.utf8/LC_CTYPE
7f62ff555000-7f62ff673000 r--p 00000000 08:01 400008                     /usr/lib/locale/en_GB.utf8/LC_COLLATE
7f62ff673000-7f62ff676000 rw-p 00000000 00:00 0 
7f62ff67c000-7f62ff67d000 r--p 00000000 08:01 400014                     /usr/lib/locale/en_GB.utf8/LC_NUMERIC
7f62ff67d000-7f62ff67e000 r--p 00000000 08:01 399484                     /usr/lib/locale/en_GB.utf8/LC_TIME
7f62ff67e000-7f62ff67f000 r--p 00000000 08:01 399435                     /usr/lib/locale/en_GB.utf8/LC_MONETARY
7f62ff67f000-7f62ff680000 r--p 00000000 08:01 399511                     /usr/lib/locale/en_GB.utf8/LC_MESSAGES/SYS_LC_MESSAGES
7f62ff680000-7f62ff681000 r--p 00000000 08:01 400015                     /usr/lib/locale/en_GB.utf8/LC_PAPER
7f62ff681000-7f62ff682000 r--p 00000000 08:01 399480                     /usr/lib/locale/en_GB.utf8/LC_NAME
7f62ff682000-7f62ff683000 r--p 00000000 08:01 399436                     /usr/lib/locale/en_GB.utf8/LC_ADDRESS
7f62ff683000-7f62ff684000 r--p 00000000 08:01 399437                     /usr/lib/locale/en_GB.utf8/LC_TELEPHONE
7f62ff684000-7f62ff685000 r--p 00000000 08:01 400011                     /usr/lib/locale/en_GB.utf8/LC_MEASUREMENT
7f62ff685000-7f62ff68c000 r--s 00000000 08:01 397931                     /usr/lib/gconv/gconv-modules.cache
7f62ff68c000-7f62ff68d000 r--p 00000000 08:01 399438                     /usr/lib/locale/en_GB.utf8/LC_IDENTIFICATION
7f62ff68d000-7f62ff68f000 rw-p 00000000 00:00 0 
7f62ff68f000-7f62ff690000 r--p 0001f000 08:01 262258                     /lib/ld-2.11.1.so
7f62ff690000-7f62ff691000 rw-p 00020000 08:01 262258                     /lib/ld-2.11.1.so
7f62ff691000-7f62ff692000 rw-p 00000000 00:00 0 
7fffd08b2000-7fffd08c7000 rw-p 00000000 00:00 0                          [stack]
7fffd09f2000-7fffd09f3000 r-xp 00000000 00:00 0                          [vdso]
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
*/
