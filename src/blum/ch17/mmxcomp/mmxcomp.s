.section .data
value0:
	.short	10, 20, -30, 40
value1:
	.short	10, 40, -30, 45
output:
	.ascii	"Comparison is (10==10), (20==40), (-30==-30), (40==45)\n"
	.ascii	"Result should be true, false, true, false\n"
	.asciz	"Result is 0x%X, 0x%X, 0x%X, 0x%X\n"

.section .bss

.section .text
	.globl	_start

_start:

	movq	value0, %mm0
	movq	value1, %mm1
	pcmpeqw	%mm1, %mm0
	movq	%mm0, %rbx

	xor	%rsi, %rsi
	xor	%rdx, %rdx
	xor	%rcx, %rcx

	movw	%bx, %si
	shr	$0x10, %rbx
	movw	%bx, %dx
	shr	$0x10, %rbx
	movw	%bx, %cx
	shr	$0x10, %rbx
	movq	%rbx, %r8

	leaq	output, %rdi
	movw	$0x04, %ax
	call	printf

	movq	$0x3c, %rax
	movq	$0x00, %rdi
	syscall
