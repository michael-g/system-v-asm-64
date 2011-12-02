.section .data
.align	0x10			# align to a 15-byte boundary

value1:
	.float	43.65
value2:
	.int	22
value3:
	.float	76.34
value4:
	.float	3.1
value5:
	.float	12.43
value6:
	.int	6
value7:
	.float	140.2
value8:
	.float	94.21
output:
	.asciz	"the result is %f\n"

.section .text

.globl _start

_start:

	nop

	finit
#
# perform the equation:
#  ((43.65 / 22) + (76.34 * 3.1)) / ((12.43 * 6) - (140.2 / 94.21))
#
	flds	value1		# load .float into st(0)
	fidiv	value2		# divide st(0) by value2; store result in st(0)
	flds	value3		# load .float into st(0)
	fmuls	value4
	faddp

	flds	value5
	fimul	value6
	flds	value7
	fdivs	value8
	fsubrp	%st(0), %st(1)
	
	fdivrp	%st(0), %st(1)

	fstl	-0x08(%rsp)		# Use (what I think is) the red-zone for tmp storage
	movq	-0x08(%rsp), %xmm0	# copy from memory to XMM0 - doesn't seem to be a way to do this in a single operation

	movq	$output, %rdi
	movw	$0x1, %ax
	call	printf


	movq	$0x3c, %rax
	movq	$0x00, %rdi
	syscall

