.section .data
	.align 0x10
value0:
	.float	12.34, 2345., -93.2, 10.44
value1:
	.float	39.234, 21.4, 100.94, 10.56
output:
	.asciz	"Result is %f, %f, %f, %f\n"

.section .bss
	.lcomm	result, 0x10

.section .text
	.globl	_start

_start:

	movaps	value0, %xmm0		# cpoy values from memory to xxm0 and xxm1
	movaps	value1, %xmm1

	addps	%xmm1, %xmm0		# add xmm1 to xxm0, store result in xmm0
	sqrtps	%xmm0, %xmm0		# perform sqrt of xmm0, store result in xmm0
	maxps	%xmm1, %xmm0		# compare and retain max of xmm0/1 in xmm0

	movaps	%xmm0, result		# store xmm0 in address result

	movss	result+0x00, %xmm0	# move single scalar to xxm0
	cvtss2sd	%xmm0, %xmm0	# convert single scalar to double scalar, otherwise
	movss	result+0x04, %xmm1	# + printf doesn't work (it needs double values)
	cvtss2sd	%xmm1, %xmm1
	movss	result+0x08, %xmm2
	cvtss2sd	%xmm2, %xmm2
	movss	result+0x0C, %xmm3
	cvtss2sd	%xmm3, %xmm3

	leaq	output, %rdi		# load address of format string
	movw	$0x04, %ax		# set number of arguments
	call	printf			# invoke printf

	movq	$0x00, %rdi
	call	exit

