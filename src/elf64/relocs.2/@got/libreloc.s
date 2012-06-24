
.section .rodata
Lhello:
	.asciz	"Hello!"

.section .text
	.globl	someRelocations
	.type	someRelocations, STT_FUNC
someRelocations:

	movq	$Lhello@GOT, %rax              # Store the offset from GOT to its entry for sayHello in RAX
	leaq	_GLOBAL_OFFSET_TABLE_(%rip), %rcx  # Store the address of _GLOBAL_OFFSET_TABLE_ in RCX
	addq	%rcx, %rax                         # Calculate abs address of sayHello 
	movq	(%rax), %rdi
	call	puts@PLT
	ret
