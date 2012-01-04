.section .data
	.align	0x10
value0:
	.double	10.42, -5.33
value1:
	.double	4.25, 2.1
value2:
	.int	10, 20, 30, 40
value3:
	.int	5, 15, 25, 35
output0:
	.asciz	"xmm0 contains %f and %f\n"
output1:
	.asciz	"xmm2 contains %d, %d, %d and %d\n"

.section .bss
	.align	0x10
	.lcomm	result0, 0x10
	.lcomm	result1, 0x10

.section .text
	.globl	_start
_start:
	nop

	movapd	value0, %xmm0
	movapd	value1, %xmm1
	movdqa	value2, %xmm2
	movdqa	value3, %xmm3

	mulpd	%xmm1, %xmm0
	paddd	%xmm3, %xmm2

	movapd	%xmm0, result0
	movdqa	%xmm2, result1

	movb	$0x02, %al
	movq	result0+0x08, %xmm1
	leaq	output0, %rdi
	call	printf

	movb	$0x04, %al
	leaq	output1, %rdi
	xor	%rsi, %rsi
	movl	result1, %esi
	xor	%rdx, %rdx
	movl	result1+0x04, %edx
	xor	%rcx, %rcx
	movl	result1+0x08, %ecx
	xor	%rbx, %rbx
	movl	result1+0x0C, %ebx
	movq	%rbx, %r8
	call	printf

	movq	$0x00, %rdi
	call	exit

