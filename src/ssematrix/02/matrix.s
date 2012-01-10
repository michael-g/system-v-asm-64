.section .data
	.align 0x10

matrix0:      	                  	# [ 1, 2 ]
	.float	1.0, 2.0, 3.0, 4.0	# [ 3, 4 ]
matrix1:      	                  	# [ 5, 6 ]
	.float	5.0, 6.0, 7.0, 8.0	# [ 7, 8 ]
outfmt:
	.ascii	"Result is [ %f, %f ]\n"
	.asciz	"          [ %f, %f ]\n"

.section .text
	.globl	_start
_start:
	movaps	matrix0, %xmm0
	movaps	matrix1, %xmm1	

# First round of multiplications will be [ 1*5, 2*7, 3*5, 4*7 ]
# which from matrix1 are indices [ 0, 2, 0, 2 ] and hence values
# 0 + 8 + 0 + 128 = 136 = 0x88
	pshufd	$0x88, %xmm1, %xmm8
	mulps	%xmm0, %xmm8

# Second round of multiplications will be [ 1*6, 2*8, 3*6, 4*8 ]
# which from matrix1 are indices [ 1, 3, 1, 3 ] and hence values
# 1 + 12 + 16 + 192 = 221 = 0xDD
	pshufd	$0xDD, %xmm1, %xmm7
	mulps	%xmm0, %xmm7
	addps	%xmm7, %xmm8

# ... and, inevitably, we reach the verbose printf section. It 
# doesn't seem possible simply to shift an entire XMM register 
# right by the size of a double-word, so we use the probably 
# quite slow PSHUFD instruction. We're also contending horribly
# on registers so it's unlikely to be an optimal instruction 
# sequence.
	cvtss2sd %xmm8, %xmm0
	pshufd	$0x39, %xmm8, %xmm8	# 1+8+48+0 = 57 = 0x39
	cvtss2sd %xmm8, %xmm1
	pshufd	$0x39, %xmm8, %xmm8
	cvtss2sd %xmm8, %xmm2
	pshufd	$0x39, %xmm8, %xmm8
	cvtss2sd %xmm8, %xmm3
	leaq	outfmt, %rdi
	movb	$0x04, %al
	call	printf

	movq	$0x3c, %rdi
	call	exit
