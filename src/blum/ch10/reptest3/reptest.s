.section .data
value1:
	.asciz	"The quick brown fox etc\n"

	.equ	v1len, . - value1

.section .bss
	.lcomm	result1, v1len

.section .text
	.globl	_start

_start:

	nop

#	movq	$v1len, %rax		# Copy string length to accumulator
#	movq	$0x08, %rbx		# Load a divisor of '8' into rbx
#	divq	%rbx			# Perofrm unsigned division. Quotient to rax; remainder to rdx

#
# Alternate method uses SHR $3 to use the quad-word copy
#
	movq	$v1len, %rcx		# Copy string length to counter (rcx)
	shr	$0x03, %rcx		# Use SHR to divide by 8

	movq	$value1, %rsi		# Use '$' addressing to copy address into RSI
	leaq	result1, %rdi		# Demonstrate LEA (without '$') to copy address into RDI
	cld				# Clear the DF flag (direction bit). MOVS will increment addresses in rsi/rdi
rep	movsq				# Quad-copy the string from value1->result1

	movq	$v1len, %rcx		# Copy string length to counter again
	andq	$0x07, %rcx		# Use AND to find remainder of division by 8 
rep	movsb

	movq	$0x3c, %rax
	movq	$0x00, %rdi
	syscall
