.section .data
newvalue:
	.byte	0x7F, 0x00

.section .bss
	.lcomm control, 2

.section .text
.globl _start

_start:

	nop

	fstcw	control
	fldcw	newvalue
	fstcw	control

	movq	$0x3C, %rax
	movq	$0x00, %rdi
	syscall
