.section .data
value1:
	.float	10.923
value2:
	.float	4.5532

.section .text
	.globl	_start

_start:

	nop 
	finit

	flds	value1		# Load 10.923 into st0
	fcoms	value2		# compare it to 4.5532, setting C0, C2, C3 flags
	fstsw			# Store the status word in register AX
	sahf			# Move bits 0, 2, 4, 6 and 7 of AH into the EFLAGS carry, 
				#   parity, aligned, zero and sign flags respectively. 
				#   C0 -> carry
	ja	greater		#   C2 -> parity
	jb	lessthan	#   C3 -> zero flag

	movq	$0x3c, %rax
	movq	$0x00, %rdi
	syscall

greater:
	movq	$0x3c, %rax
	movq	$0x02, %rdi
	syscall

lessthan:
	movq	$0x3c, %rax
	movq	$0x01, %rdi
	syscall

