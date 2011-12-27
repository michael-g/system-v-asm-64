.section .data
words0:
	.short	2, 4, 8, 16
words1:
	.short	32, 64, 128, 256
output:
	.asciz	"Values are %d, %d, %d, %d\n"

.section .bss
	.lcomm	result, 16		# Values are 4 32 bit integers

.section .text
	.globl	_start

_start:
	nop

	movq	words0, %mm0
	movq	words1, %mm1
	
	pmullw	%mm1, %mm0		# multiply and store the low-word results in %mm0

	movq	%mm0, %rcx		# move to a general purpose register
	movw	%cx, result		# Store lowest word in address result+0
	ror	$0x10, %rcx		# Rotate value in register right by 16 bits
	movw	%cx, result+0x04	# Store low-word in address result+4
	ror	$0x10, %rcx
	movw	%cx, result+0x08	# Store low-word in address result+8
	ror	$0x10, %rcx
	movw	%cx, result+0x12	# Store low-word in address result+12

	pmulhw	%mm1, %mm0		# multiply and store the high-word results in %mm0
	movq	%mm0, %rcx
	movw	%cx, result+0x02	# Store the low-word in result+2 (to make an int)
	ror	$0x10, %rcx
	movw	%cx, result+0x06
	ror	$0x10, %rcx
	movw	%cx, result+0x10
	ror	$0x10, %rcx
	movw	%cx, result+0x14

	movw	$0x04, %ax		# Number of arguments to varargs function
	movq	$output, %rdi		# Address of format string
	xor	%rsi, %rsi		# Clear the high-bytes of the parameter registers
	xor	%rdx, %rdx
	xor	%rcx, %rcx
	xor	%ebx, %ebx
	movl	result, %esi		# move int at result[0] into %rsi
	movl	result+0x04, %edx	# move int at result[1] into %rdx
	movl	result+0x08, %ecx	# move int at result[2] into %rcx
	movl	result+0x12, %ebx	# can't 'movl' into %r8, so go via %ebx
	movq	%rbx, %r8
	call	printf

	movq	$0x3c, %rax
	movq	$0x01, %rdi
	syscall
