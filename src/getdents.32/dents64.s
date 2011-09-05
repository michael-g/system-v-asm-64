#
# see /usr/include/asm-x86_64/unistd.h 
#
# 
#define __NR_getdents                           78
#__SYSCALL(__NR_getdents, sys_getdents)
#define __NR_getdents64                        217
#__SYSCALL(__NR_getdents64, sys_getdents64)

section .data
	asciz_dot:    	.asciz	"."
	header_str:	.asciz	"%10s\t%10s\t%10s\t%s\n"
	dirent_str:	.asciz	"%10d\t%10d\t%10d\t%s\n"
	inode_str:	.asciz	"inode"
	offset_str:	.asciz	"offset"
	len_str:	.asciz	"length"
	name_str:	.asciz	"name"
	
.section .bss

	.lcomm	buffer, 2048

.section .text

.globl _start

# parameter: base-address in EAX
# Returns: 
#	EAX	inode
#	EBX	offset
#	ECX	length
#	EDX	.asciz name[0]-address
#
# Where dirent struct looks like 
#  struct dirent {
#	  long d_ino;                 /* inode number */
#	  off_t d_off;                /* offset to next dirent */
#	  unsigned short d_reclen;    /* length of this dirent */
#	  char d_name [NAME_MAX+1];   /* filename (null-terminated) */
#  }
#
# d_ino  is  an  inode number.  
# d_off is the distance from the start of the directory to the start of the next dirent.
# d_reclen is the size of this entire dirent.  
# d_name is a null-terminated filename.
#

read_dirent:

	xorl	%ecx, %ecx		# Clear the ECX register as only the CX part will be overwritten
	leal	10(%eax), %edx		# Store the effective address of 'name' in EDX
	movw	 8(%eax),  %cx		# Store the uint16 'length' in CX
	movl	 4(%eax), %ebx		# Store the uint32 'offset' in EBX
	movl	  (%eax), %eax		# Store the uint32 'inode' value in EAX (clobbering the base-address in the process)

	ret	

_start:

	movl	%esp, %ebp		# store SP in BP
	
	cmp	$1, (%esp)		# check ARGC
	je	curr_dir		# if == 1 jump to curr_dir
	movl	8(%ebp), %ebx		# use ARG[1] as directory name
	jmp	open_dir
	
curr_dir:	
	movl	$asciz_dot, %ebx	# pointer to asciz filename
	
open_dir:
	movl	$5, %eax		# EAX sys_open
	                 		# EBX was set above, as ARG[1] or '.'
	movl	$0, %ecx		# ECX file access bits: read only
	movl	$256, %edx		# EDX file permission flags: read by owner

	int	$0x80

	pushl	%eax			# store FD on stack: -4(%ebp)

	movl	$141, %eax		# sys_getdents
	movl	-4(%ebp), %ebx		# File descriptor
	movl	$buffer, %ecx		# struct dirent* pointer
	movl	$2048, %edx		# count

	int	$0x80

	pushl	$buffer			# store base-address           -8(%ebp)
	pushl	%eax			# store number of bytes read: -12(%ebp)
	addl	$buffer, %eax		# calc end of buffer
	pushl	%eax			# store end-of-records:       -16(%ebp)

write_header:
	pushl	$name_str		# write heading
	pushl	$len_str
	pushl	$offset_str
	pushl	$inode_str
	pushl	$header_str
	call	printf
	addl	$20, %esp		# clear parameters

	movl	$buffer, %eax		# move buffer address -> EAX
	pushl	%eax			# store base-address on stack
	xorl	%ebx, %ebx		# zero-out EBX

write_line:
	#
	# in:  EAX to contain start of record
	#
	# EBX contains byte-length of current record
	#

	call	read_dirent
	
	pushl	%edx
	pushl	%ecx
	pushl	%ebx
	pushl	%eax
	pushl	$dirent_str		# push format string onto the stack
	call	printf

	movl	12(%esp), %ecx		# restore ECX (length) from _stack_ (using ESP, not EBP)
	
	addl	$20, %esp		# clear parameters
	
	movl	-8(%ebp), %eax		# restore base-address from stack-variable

	addl	%ecx, %eax		# add length+base to store address of next record in EAX
	cmpl	-16(%ebp), %eax		# compare with end-of-records pointer

	je	close_fd		# if equal, jump to exit

	movl	%eax, -8(%ebp)		# store new base-address in stack variable (and allow it to persist in EAX for next call to read_dirent)

	jmp	write_line		# if not, repeat loop

close_fd:

	movl	$6, %eax		# system.close
	movl	-4(%ebp), %ebx		# FD from stack location
	int	$0x80

exit:



	movl	$1, %eax
	movl	$0, %ebx
	int	$0x80

