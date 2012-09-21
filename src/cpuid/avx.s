.section .rodata
hasAvx:
	.asciz	"AVX available"
noHasAvx:
	.asciz	"AVX unavailable"

.section .text
	.globl	_start
	.type	_start, STT_FUNC

_start:
	mov	%rsp, %rbp
	sub	$0x80, %rsp		# reserve stack space
	and	$~0x1F, %rsp		# align stack
	
	xor	%eax, %eax		# clear input param for cpuid
	cpuid
	movl	%ebx, (%rsp)		# Genu
	movl	%edx, 4(%rsp)		# ineI
	movl	%ecx, 8(%rsp)		# ntel
	movb	$0x00, 0x0c(%rsp)	# write null byte to create C-string
	leaq	(%rsp), %rdi		# set param[0] for puts
	call	puts@PLT

	mov	$0x01, %eax
	cpuid
	lea	noHasAvx, %rdi
	test	$0x10000000, %ecx	# test for AVX
	jz	.LprintAvx
	lea	hasAvx, %rdi
.LprintAvx:
	call	puts@PLT

	mov	$0x3c, %rax
	mov	$0x00, %rdi
	syscall

