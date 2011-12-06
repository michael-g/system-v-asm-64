.section .data
value:
	.float	10.0
scale1:
	.float	3.14159265
scale2:
	.float	-3.14159265

.section .bss
	.lcomm	result1, 4
	.lcomm	result2, 4

.section .text
	.globl	_start

_start:
	nop

	finit

	flds	scale1
	flds	value
	fscale
	fsts	result1

	flds	scale2
	flds	value
	fscale
	fsts	result2

	movq	$0x3c, %rax
	movq	$0x00, %rdi
	syscall

	
