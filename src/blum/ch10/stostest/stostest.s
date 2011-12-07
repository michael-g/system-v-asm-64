.section .data
space:
	.ascii	" "

.section .bss
	.lcomm	buffer, 256

.section .text
	.globl	_start

_start:
	nop
	leaq	space, %rsi
	leaq	buffer, %rdi

	movq	$0x100, %rcx
	cld
	lodsb
rep	stosb

	movq	$0x3c, %rax
	movq	$0x00, %rdi
	syscall
