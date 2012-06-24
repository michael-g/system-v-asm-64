
.section .rodata
Lhello:
	.asciz	"Hello!"

.section .text
	.globl	someRelocations
	.type	someRelocations, STT_FUNC
someRelocations:
	mov	Lhello@GOTPCREL(%rip), %rdi
	leaq	Lhello@GOTPCREL(%rip), %rsi
	call	puts@PLT
	ret

