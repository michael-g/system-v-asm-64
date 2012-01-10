#
# Implements the branchless 'abs' routine demonstrated in Leiterman's 32/64-BIT ASM 
# Architecture Book. 
# Uses the SAL instruction to generate a -1 or 0 bitmask from the sign-bit of the 
# argument. The argument is XOR'd with the mask, flipping a negative number since its
# mask is -1 (while a positive number remains unchanged). We then subtract the mask 
# from the result, a no-op for a positive number, but the subtraction of -1 for a 
# negative argument.
#
.section .data
outfmt:
	.asciz	"Value is %d\n"

.section .text
	.globl	_start
_start:
	mov	%rsp, %rbp

	leaq	0x10(%rbp), %rdi
	movq	(%rdi), %rdi
	call	atoi

	mov	%rax, %rcx	# Copy input value for later
	sar	$0x3F, %rcx	# Proliferate sign-bit across whole register
	xor	%rcx, %rax	# XOR RCX (0 or -1) with input value
	sub	%rcx, %rax	# Subtract mask (0 or -1) from above result

	mov	%rax, %rsi
	leaq	outfmt, %rdi
	movb	$0x01, %al
	call	printf

	movq	$0x00, %rdi
	call	exit

