.section .data
string1:
	.asciz	"This is a TEST, that will be all.\n"
length:
	.quad	. - string1

.section .text
	.globl _start

_start:

	leaq	string1, %rsi
	movq	%rsi, %rdi
	movq	length, %rcx

	cld

loop1:
	lodsb
	cmpb	$'a', %al
	jl	skip
	cmpb	$'z', %al
	jg	skip

	subb	$0x20, %al
skip:
	stosb
	loop	loop1
end:
	movq	$string1, %rdi
	xor	%rax, %rax
	call	printf

	movq 	$0x3c, %rax
	movq	$0x00, %rdi
	syscall
