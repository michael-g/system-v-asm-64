.section .data
value1:
	.int 40
value2:
	.float 92.4405
value3:
	.double 221.440321

.section .bss
	.lcomm	int1, 4
	.lcomm	control, 2
	.lcomm	status, 2
	.lcomm	result, 4

.section .text
.globl _start

_start:
	nop

	finit
	fstcw	control		# Float-STore-Control-Word
	fstsw	status		# Float-STore-Control-Word
	filds	value1		# Float-Integer-LoaD-Short
	fists	int1		# Float-Integer-STore-Short
	flds	value2		# Float-LoaD-Short
	fldl	value3		# Float-LoaD-Long
	fst	%st(4)		# Float-STore (copy) st(0) in st(4). 
	fxch	%st(1)		# Float-eXCHange st(0) and st(1)
	fstps	result		# Float-STore-Pop-Short into 'result'

	movq	$0x3c, %rax
	movq	$0x00, %rdi
	syscall
