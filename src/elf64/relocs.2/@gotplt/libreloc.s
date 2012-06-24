
.section .rodata
Lhello:
	.asciz	"Hello!"

.section .got                                      # It's happy in .got (and .text), but not .got.plt
#	.globl	LhelloOff
LhelloOff:
	.quad	sayHello@GOTPLT
	
.section .text
	.globl	someRelocations
	.type	someRelocations, STT_FUNC
someRelocations:
	call	sayHello@PLT
	movq	LhelloOff(%rip), %rax              # Store the offset from GOT to its entry for sayHello in RAX
	leaq	_GLOBAL_OFFSET_TABLE_(%rip), %rcx  # Store the address of _GLOBAL_OFFSET_TABLE_ in RCX
	addq	%rcx, %rax                         # Calculate abs address of sayHello 
	call	*(%rax)

	ret

	.globl	sayHello
	.type	sayHello, STT_FUNC
sayHello:
	movq	Lhello@GOTPCREL(%rip), %rdi
	call	puts@PLT
	ret
