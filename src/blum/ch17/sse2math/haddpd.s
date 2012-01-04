.section .data
	.align	0x10
value0:
	.double	15.0, 20.0
value1:
	.double	25.0, 30.0
outfmt:
	.asciz	"Results are %f (15.0+20.0) and %f (25.0+30.0)\n"

.section .bss
	.align	0x10
	.lcomm	result, 0x10

.section .text
	.globl	_start

_start:
	nop

	movapd	value0, %xmm0
	movapd	value1, %xmm1

	haddpd	%xmm1, %xmm0

	movapd	%xmm0, result

	movsd	result, %xmm0
	movsd	result+0x08, %xmm1
	movq	$outfmt, %rdi
	movb	$0x02, %al
	call	printf
	
	movq	$0x00, %rdi
	call	exit

