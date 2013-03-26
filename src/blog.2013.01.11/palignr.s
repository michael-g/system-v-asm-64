.section .text

.type	_start, STT_FUNC
.globl	_start

_start:
	mov	$0x32, %rax
	xor     %rdx, %rdx
	and	$~0x0f, %rsp
.L0:
	movb	%al, (%rsp, %rax)
	sub	$0x01, %rax
	jne	.L0

	movdqa	(%rsp), %xmm0
	movdqa	0x10(%rsp), %xmm1
	movdqa	%xmm1, %xmm2

	palignr	$1, %xmm0, %xmm2


	mov	$0x3c, %rax
	xor	%rdi, %rdi
	syscall
