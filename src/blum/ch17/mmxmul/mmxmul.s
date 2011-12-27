.section .data
words0:
	.short	2, 4, 8, 16
words1:
	.short	32, 64, 128, 256
output:
	.asciz	"Values are %d, %d, %d, %d\n"

.section .bss
	.lcomm	result, 16

.section .text
	.globl	_start

_start:
	nop

	movq	words0, %mm0
	movq	words1, %mm1
	
	pmullw	%mm1, %mm0

	movq	%mm0, %rcx
	movw	%cx, result
	ror	$0x10, %rcx
	movw	%cx, result+0x20
	ror	$0x10, %rcx
	movw	%cx, result+0x40
	ror	$0x10, %rcx
	movw	%cx, result+0x60

	pmulhw	%mm1, %mm0
	movq	%mm0, %rcx
	movw	%cx, result+0x10
	ror	$0x10, %rcx
	movw	%cx, result+0x30
	ror	$0x10, %rcx
	movw	%cx, result+0x50
	ror	$0x10, %rcx
	movw	%cx, result+0x70

	movw	$0x04, %ax
	movq	$output, %rdi
	xor	%rsi, %rsi
	xor	%rdx, %rdx
	xor	%rcx, %rcx
	xor	%r8, %r8
	movw	result, %rsi
	movw	result+0x20, %rdx
	movw	result+0x40, %rcx
	movw	result+0x60, %r8
	call	printf

	movq	$0x3c, %rax
	movq	$0x01, %rdi
	syscall
