
.section .rodata
Lhello:
	.asciz	"Hello!"

.section .text
	.globl	someRelocations
	.type	someRelocations, STT_FUNC
someRelocations:
	call	sayHello@PLT
	ret

	.globl	sayHello
	.type	sayHello, STT_FUNC
sayHello:
	movq	Lhello@GOTPCREL(%rip), %rdi
	call	puts@PLT
	ret
