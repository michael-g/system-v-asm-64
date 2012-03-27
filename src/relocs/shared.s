.section .rodata
localRoVar:
	.int	0x80087355

globalRoVar:
	.globl	globalRoVar
	.type	globalRoVar, STT_OBJECT
	.int	0x12345678
	

.section .data
localRwVar:
	.int	0xDEADBEEF

globalRwVar:
	.globl	globalRwVar
	.type	globalRwVar, STT_OBJECT
	.int	0xCAFEBABE

.section .bss
localBssVar:
	.skip	0x08

globalBssVar:
	.globl	globalBssVar
	.type	globalBssVar, STT_OBJECT
	.skip	0x08

.section .text
globalFunc:
	.globl	globalFunc
	.type	globalFunc, STT_FUNC

	leaq	localRoVar(%rip), %rax
	leaq	localRwVar(%rip), %rbx
	leaq	localBssVar(%rip), %rcx
	movq	globalRoVar@GOTPCREL(%rip), %rdx
	movq	globalRwVar@GOTPCREL(%rip), %rdi
	movq	globalBssVar@GOTPCREL(%rip), %rsi

	ret

