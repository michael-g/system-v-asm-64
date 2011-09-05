.section	.rodata

	.string	"HelloArgs"

.section	.text

	.globl _start

_start:
	
	nop

	pushq	%rbp
	movq	%rsp, %rbp

	leaq	-16(%rbp), %rax		# Calculate address at RBP-16

	pushq	%rax			# Store pointer to -16(%rbp) on stack (at -8(%rbp))
	pushq	$0x80			# Store literal at -16(%rbp)

	movq	-8(%rbp), %rax		# Move the value of the first local var into RAX
	movq	(%rax), %rax		# Load the value at the address contained in RAX into RAX (should be 0xCAFEBABE)

	pushq	$-1			# Store -1 on the stack as a separator

	leaq	-8(%rbp), %rax		# Copy the address at -8(%rbp) into RAX
	movq	(%rax), %rax		# Copy the value at the address contained in RAX to RAX

	pushq	$-1			# Store -1 on the stack as a separator

	leave
	ret

