.section .data
value1:
	.float	20.5
value2:
	.float	10.9

.section .text
	.globl	_start

_start:
	
	nop
	finit

	flds	value1
	flds	value2
	
	fcomi	%st(1)
	fcmovb	%st(1), %st(0)

	movq	$0x3c, %rax
	movq	$0x00, %rdi
	syscall
