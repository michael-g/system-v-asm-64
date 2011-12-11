.section .data
value1:
	.ascii	"This is a test of the CMPS instructions"
value2:
	.ascii	"This is a test of the CMPS Instructions"
strlen:
	.quad	. - value2
iseq:
	.asciz	"Values are equal\n"
isneq:
	.asciz	"Values are different\n"

.section .text
	.globl	_start
_start:

	nop

	leaq	value1, %rsi
	leaq	value2, %rdi
	movq	strlen, %rcx
	cld

repe	cmpsb

	leaq	iseq, %rdi
	je	equal
	leaq	isneq, %rdi
equal:
	xor	%rax, %rax
	call	printf

	movq	$0x3c, %rax
	movq	$0x00, %rdi
	syscall
