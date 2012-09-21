.section .rdata,"dr"
.LC3:
	.ascii "Hello %f, %f, %f, %f\15\12\0"

.section	.text.startup,"x"
	.p2align 4,,15
	.globl	main
main:
	subq	$72, %rsp
	call	__main
	movabsq	$4609884578576439706, %r9
	movabsq	$4609434218613702656, %r8
	movabsq	$4607182418800017408, %rdx
	movabsq	$4610334938539176755, %rax
	movq	%r9, 56(%rsp)
	movsd	56(%rsp), %xmm3
	movq	%r8, 56(%rsp)
	movsd	56(%rsp), %xmm2
	movq	%rdx, 56(%rsp)
	movsd	56(%rsp), %xmm1
	movq	%rax, 32(%rsp)
	leaq	.LC3(%rip), %rcx
	call	printf
	xorl	%eax, %eax
	addq	$72, %rsp
	ret
	.seh_endproc
	.def	printf;	.scl	2;	.type	32;	.endef
