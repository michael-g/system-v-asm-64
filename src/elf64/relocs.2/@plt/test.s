.section .text

	.globl	test1
	.type	test1, STT_FUNC
test1:
	call	*test2@PLT(%rip)
	ret

	.globl	test2
	.type	test2, STT_FUNC
test2:
	ret
