#
# Implementation of the min function described in 32/64-BIT 80x86 Assembly 
# Language Architecture by James Leiterman. Uses a branchless technique to 
#
# Note that this implementation only works for unsigned integers. 
#
.section .data
outfmt:
	.asciz	"Min value of %d and %d is %d\n"

.section .text
	.globl	_start
_start:

	mov	%rsp, %rbp

	leaq	0x10(%rbp), %rdi
	movq	(%rdi), %rdi	# Dereference argument pointer
	call	atoi		# Parse arg[0]

	mov	%rax, %r12	# Store atoi:arg[0] in R12 (callee-saved register)

	leaq	0x18(%rbp), %rdi
	movq	(%rdi), %rdi	# Dereference argument pointer
	call	atoi		# Parse arg[1]
	
	mov	%r12, %rbx	# Retrieve atoi:arg[0] in RBX
	mov	%rax, %r13	# Store atio:arg[1] in R13
	movq	%rbx, %rcx	# Store copy of RBX in RCX

	sub	%rax, %rbx	# Subtract A from B, store in B
	sar	$0x3F, %rbx	# Bit-shift B right until only its (repeated)  sign bit remains
	and	%rbx, %rcx	# If A>B, RBX=-1, hence preserve RCX, else clear RCX
	not	%rbx		# Flip RBX
	and	%rbx, %rax	# IF A<B, RBX=-1, hence preserve RAX, else clear RAX
	or	%rax, %rcx	# Logical OR RAX and RCX
	
	leaq	outfmt, %rdi
	movq	%r13, %rsi
	movq	%r12, %rdx
	movb	$0x03, %al
	call	printf

	movq	$0x00, %rdi
	call	exit

