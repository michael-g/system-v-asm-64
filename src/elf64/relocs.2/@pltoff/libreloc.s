
.section .rodata
Lhello:
	.asciz	"Hello!"
Lgoodbye:
	.asciz	"Goodbye!"

.section .text
	.globl	someRelocations
	.type	someRelocations, STT_FUNC
someRelocations:
	movabs	$sayHello@PLTOFF, %rax          # store offset from GOT in RAX
	movabs	$sayGoodbye@PLTOFF, %rbx
	leaq	_GLOBAL_OFFSET_TABLE_(%rip), %rcx

	addq	%rcx, %rax                      # Calculate abs address of PLT entry for sayHello
	movl	2(%rax), %r9d                   # Skip the jump instruction to find the RIP-addend
	leaq	6(%r9,%rax), %rax               # Add the two numbers to get the GOT trampoline target
	    	                                # and six bytes to account for the jmp instruction bytes

	addq	%rcx, %rbx                      # Do the same for the 'sayGoodbye' function 
	movl	2(%rbx), %r11d
	leaq	6(%r11,%rbx), %rbx

	movq	(%rbx), %rdx                    # copy the contents of the GOT trampoline for sayGoodbye ...
	movq	%rdx, (%rax)                     # into the GOT trampoline for sayHello
	
	call	sayHello@PLT                    # invoke both functions to see what's happening
	call	sayGoodbye@PLT                  # if the hackery is sound it should print 'Goodbye!' twice
	ret

	.globl	sayHello
	.type	sayHello, STT_FUNC
sayHello:
	movq	Lhello@GOTPCREL(%rip), %rdi
	call	puts@PLT
	ret

	.globl	sayGoodbye
	.type	sayGoodbye, STT_FUNC
sayGoodbye:
	movq	Lgoodbye@GOTPCREL(%rip), %rdi
	call	puts@PLT
	ret
