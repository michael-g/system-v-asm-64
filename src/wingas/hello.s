# http://en.wikibooks.org/wiki/X86_Assembly/GAS_Syntax
# Create this file: 
# 	gcc -S -m64 hello.c
# Generate the executable from this file: 
#	gcc -o hello_asm.exe -m64 hello.s
#

.section .rdata,"dr"
.Lhellomsg:
	.ascii "Hello, world!\0"

.section .text
	.globl	main
main:

	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp

	call	__main
	leaq	.Lhellomsg(%rip), %rcx
	call	puts
	movl	$0, %eax
	addq	$32, %rsp
	popq	%rbp
	ret
