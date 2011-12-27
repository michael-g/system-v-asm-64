.section .data
pvalues1:
	.int	2, 16
pvalues2:
	.int	4, 8
output:
	.asciz	"Values are %d and %d\n"

.section .bss
	.lcomm	result, 8

.section .text
	.globl	_start

_start:
	
	nop
	movq	pvalues1, %mm0
	movq	pvalues2, %mm1

	paddd	%mm1, %mm0
	movq	%mm0, %rdx

	leaq	output, %rdi
	xor	%rsi, %rsi
	movl	%edx, %esi
	ror	$0x20, %rdx
	movw	$0x02, %ax
	call	printf

	movq	$0x3c, %rax
	movq	$0x02, %rdi
	syscall
