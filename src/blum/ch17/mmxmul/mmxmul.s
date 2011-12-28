.section .data
words0:
	.short	2, 4, 8, 16
words1:
	.short	32, 64, 128, 256
output:
	.ascii	"Calculation is (2*32), (4*64), (8*128), (16*256)\n"
	.ascii	"Result should be: 64, 256, 1024, 4096\n"
	.asciz	"Values are:       %d, %d, %d, %d\n"

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
	movw	%cx, result+0x00	# Store lowest word in address result+0
	shr	$0x10, %rcx		# Shift value in register right by 16 bits
	movw	%cx, result+0x04	# Store low-word in address result+4
	shr	$0x10, %rcx
	movw	%cx, result+0x08	# Store low-word in address result+8
	shr	$0x10, %rcx
	movw	%cx, result+0x0C	# Store low-word in address result+12

	movq	words0, %mm0
	pmulhw	%mm1, %mm0		# multiply and store the high-word results in %mm0

	movq	%mm0, %rcx
	movw	%cx, result+0x02	# Store the low-word in result+2 (to make an int)
	shr	$0x10, %rcx
	movw	%cx, result+0x06
	shr	$0x10, %rcx
	movw	%cx, result+0x0A
	shr	$0x10, %rcx
	movw	%cx, result+0x0E

	movw	$0x04, %ax		# Number of arguments to varargs function
	movq	$output, %rdi		# Address of format string
	xor	%rsi, %rsi		# Clear the high-bytes of the parameter registers
	xor	%rdx, %rdx
	xor	%rcx, %rcx
	xor	%rbx, %rbx
	movl	result, %esi		# move int at result[0] into %rsi
	movl	result+0x04, %edx	# move int at result[1] into %rdx
	movl	result+0x08, %ecx	# move int at result[2] into %rcx
	movl	result+0x0C, %ebx	# can't 'movl' into %r8, so go via %ebx
	movq	%rbx, %r8
	call	printf

	movq	$0x3c, %rax
	movq	$0x01, %rdi
	syscall
