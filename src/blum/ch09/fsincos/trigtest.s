.section .data
degree1:
	.float	90.0
val180:
	.int	180

.section .bss
	.lcomm	sinresult, 4
	.lcomm	cosresult, 4

.section .text
.globl _start
_start:

	nop
	finit
	flds	degree1
	fidivs	val180
	fldpi
	fmulp	%st(1)		# Multiply deg/180 by pi to get radian value in st0

	fsincos			# Calc sin & cos; sin over st0, cosine pushed onto stack (as new st0)

	fstps	cosresult	# Store and pop cosine
	fstps	sinresult	# Store and pop sine

	movq	$0x3c, %rax
	movq	$0x01, %rdi
	syscall

