
.section .rodata
Lhello:
	.asciz	"Hello!"

.section .data
Lgoodbye:
	.asciz	"Goodbye!"

.section .text
	.globl	someRelocations
	.type	someRelocations, STT_FUNC
someRelocations:
	movabs	$Lhello@GOTOFF, %rdi                # Store 64-bit offset to Lhello from the GOT in RDI
	lea	_GLOBAL_OFFSET_TABLE_(%rip), %rdx   # Get absolute address of _GLOBAL_OFFSET_TABLE_
	add	%rdx, %rdi                          # Get absolute address of Lhello
	call	puts@PLT                            # Print to stdout

	movabs	$Lgoodbye@GOTOFF, %rdi
	lea	_GLOBAL_OFFSET_TABLE_(%rip), %rdx
	add	%rdx, %rdi
	call	puts@PLT
	ret

