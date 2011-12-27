.section .data
value0:
	.short	2, 4, 8, 16
value1:
	.short	3, 9, 27, 81
output:
	.asciz	"Output is %d, %d\n"
expected:
	.asciz	"Caluclation is (2x3)+(4x9), (8*27)+(16*81)\nResult should be 42, 1512\n"

.section .bss
	.lcomm	result, 8

.section .text
	.globl	_start

_start:

	movq	$expected, %rdi
	movw	$0x00, %ax
	call	printf

	movq	value0, %mm0
	movq	value1, %mm1

	pmaddwd	%mm1, %mm0

	xor	%rsi, %rsi
	xor	%rdx, %rdx
	movq	%mm0, %rax
	movl	%eax, %esi
	ror	$0x20, %rax
	movl	%eax, %edx
	movw	$0x02, %ax
	movq	$output, %rdi
	call	printf

	movq	$0x3c, %rax
	movq	$0x01, %rdi
	syscall
