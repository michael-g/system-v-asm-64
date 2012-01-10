.section .rodata
output:
	.asciz	"The result was %d\n"
upper:
	.quad	0x4           # p/t upper: binary 100
input:
	.quad	0x0
.section .text

.globl _start

_start:

	mov	%rsp, %rbp

	leaq	0x10(%rbp), %rdi
	movq	(%rdi), %rdi
	call	atoi
	
	movq	%rax, %rdx        # copy RAX into RDX
	subq	upper, %rax       # subtract 'upper' from the input value
	sbb	%rax, %rax        # subtract RAX (with-borrow) from itself. RAX becomes either 0 or -1.
	and	%rax, %rdx        # use RAX as a mask to clear or preserve the bits in RDX
	not	%rax              # invert the bits in RAX. RAX is either -1 or 0.
	andq	upper, %rax       # set RAX = 0 or value of 'upper'
	add	%rax, %rdx        #
                             
	movq	$output, %rdi     # Output the result
	movq	%rdx, %rsi
	movq	$1, %rax
	call	printf

	movq	$60, %rax
	movq	$0, %rdi
	syscall

