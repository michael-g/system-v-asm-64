.section .data
	.align	0x10			# Required for use with the MOVAPS instruction
value0:
	.float	12.34, 2345.0, -93.2, 10.44
value1:
	.float	12.34, 21.4, -93.2, 10.45
cmpfmt:
	.asciz	"Comparison [%d] is %f == %f\n"
resfmt:
	.asciz	"Result [%d] was %s\n"
truestr:
	.asciz	"true"
falsestr:
	.asciz	"false"

.section .bss
	.align 0x10			# Required by MOVAPS
	.lcomm result, 0x10		# Space sufficient for one XMM register
 
.section .text
	.globl	_start

_start:
	nop

	subq	$0x10, %rsp		# Add alignment-friendly stack space
	movq	%r12, (%rsp)		# Store a callee-saved register which will be used
	movq	%r13, 8(%rsp)		# Same for R13

	movq	$0x04, %rcx		# Set loop-iteration count limit

	xor	%r12, %r12		# Clear register for loop counting
.Lcountloop:
	movss	value0(,%r12,4), %xmm0	# Set first printf argument
	movss	value1(,%r12,4), %xmm1	# ... and set the second
	cvtss2sd	%xmm0, %xmm0	# Expand them to be 8-byte double values
	cvtss2sd	%xmm1, %xmm1
	movb	$0x03, %al		# Set the argument count
	movq	%rcx, %r13		# Store RCX in a callee-saved register
	movq	%r12, %rsi		# Load the counter/index value for printing
	leaq	cmpfmt, %rdi		# Load the address of the format-string
	call	printf			
	movq	%r13, %rcx		# Restore RCX
	incq	%r12			# Increment R12 to address next float value
	loop	.Lcountloop		

	movaps	value0, %xmm0		# Load the data for the comparison
	movaps	value1, %xmm1		#
	cmpeqps	%xmm1, %xmm0		# Compare the data
	movaps	%xmm0, result		# Store the packed float values in &result

	movq	$0x00, %r12		# Prepare counter for result printing
	movq	$0x04, %rcx		# Set limit for loop
.Lprintloop:
	movq	%r12, %rsi		# Copy loop-count to RSI for printing
	xor	%rdx, %rdx		# Clear RDX for write to EDX
	movl	result(,%r12,4), %edx	# Copy 4-byte integer result to EDX
	cmpl	$0x00, %edx		# Compare with zero
	je	.Lfalse			
	leaq	truestr, %rdx		# Set the address of the string 'true' 
	jmp	.Lskipfalse
.Lfalse:
	leaq	falsestr, %rdx		# Set the address of the string 'false'
.Lskipfalse:
	leaq	resfmt, %rdi		# 
	movb	$0x02, %al		#
	movq	%rcx, %r13		# Save the RCX value
	call	printf
	movq	%r13, %rcx		# Restore the RCX value
	incq	%r12			# Increment the loop counter
	loop	.Lprintloop

	movq	8(%rsp), %r13		# Restore R13
	movq	(%rsp), %r12		# Restore R12
	addq	$0x10, %rsp		# Reset stack pointer

	movq	$0x00, %rdi
	call	exit


