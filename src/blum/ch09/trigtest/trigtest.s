.section .data
degree1:
	.float	90.0
val180:
	.int	180

.section .bss
	.lcomm	radian1, 4
	.lcomm	result1, 4
	.lcomm	result2, 4

.section .text
.globl _start
_start:
	nop
	finit
	flds	degree1
	fidivs	val180		# Since the trig functions operate in radians, convert the degrees by dividing by 180 and multiplying by pi
	fldpi
	fmul	%st(1), %st(0)	# Multiply value by pi; store result over pi in st(0)
	fsts	radian1
	fsin			# Calculate the sin(st0) value 
	fsts	result1		#
#	flds	radian1		# Typo by Mr. Blum
	flds	radian1		#
	fcos			# Calculate the cos(st0) value
	fsts	result2
	
	movq	$0x3c, %rax
	movq	$0x00, %rdi
	syscall

