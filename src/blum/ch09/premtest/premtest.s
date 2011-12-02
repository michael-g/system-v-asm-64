.section .data
value1:
	.float	20.65
value2:
	.float	3.97
output:
	.asciz	"The result is %e\n"

.section .bss
	.lcomm	result, 8

.section .text
.globl _start

_start:

	finit
	flds	value2
	flds	value1
loop:
	fprem1
	fstsw	%ax		# Store status-word in AX
	testb	$0x04, %ah	# Test bit C2 of the status word - at bit 2 in the upper byte
	jnz	loop

	fstl	result		# Store remainder as 8-byte double in 'result'
	
	movq	$output, %rdi	# Store address of 'output' in RDI
	movq	result, %xmm0	# Store the remainder in xmm0
	movq	$0x01, %rax	# just the one var-arg
	call	printf		# Call printf

	movq	$0x3c, %rax	# sys-exit, immediate values
	movq	$0x00, %rdi	# status-code
	syscall

