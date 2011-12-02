.section .data

.section .bss
	.lcomm	status, 0x02

.section .text
.globl _start

_start:
	nop

	fstsw	status

	movq	$0x3C, %rax
	movq	$0x00, %rdi
	syscall
