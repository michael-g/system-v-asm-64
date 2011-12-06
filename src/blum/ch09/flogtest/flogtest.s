.section .data
value:
	.float	12.0
base:
	.float	10.0

.section .bss
	.lcomm	result, 4

.section .text
	.globl	_start

_start:

#
# Program to compute the log base 10 of the value 12.0
#
# To perform base 'b' log calculations, the following formula can be used:
# 
#   log (base b) X = (1/log(base 2) b) * log(base 2) X
#
	nop
	finit

	fld1			# Pushes 1 onto the FPU stack
	flds	base		# Pushes 10.0 onto the stack
	fyl2x			# performs the base 2 log of that value

	fld1			# Pushes 1.0 onto the stack
	fdivp			# divide 1 (st0) by result (st1)
	flds	value		# Pushes 12.0 onto the stack
	fyl2x			# Performs the final log base 2 oepration
	fsts	result

	movq	$0x3c, %rax
	movq	$0x00, %rdi
	syscall
