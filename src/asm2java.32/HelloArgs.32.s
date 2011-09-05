	.file	"HelloArgs.c"
	.section	.rodata
.LC0:
	.string	"HelloArgs"
	.text
.globl Java_HelloArgs_sayHello
	.type	Java_HelloArgs_sayHello, @function
Java_HelloArgs_sayHello:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$20, %esp
	call	__i686.get_pc_thunk.bx
	addl	$_GLOBAL_OFFSET_TABLE_, %ebx
	movl	8(%ebp), %eax
	movl	(%eax), %edx
	leal	.LC0@GOTOFF(%ebx), %eax
	movl	%eax, 4(%esp)
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	movl	24(%edx), %eax
	call	*%eax
	movl	%eax, -8(%ebp)
	addl	$20, %esp
	popl	%ebx
	leave
	ret
	.size	Java_HelloArgs_sayHello, .-Java_HelloArgs_sayHello
	.section	.gnu.linkonce.t.__i686.get_pc_thunk.bx,"ax",@progbits
.globl __i686.get_pc_thunk.bx
	.hidden	__i686.get_pc_thunk.bx
	.type	__i686.get_pc_thunk.bx, @function
__i686.get_pc_thunk.bx:
	movl	(%esp), %ebx
	ret
	.section	.note.GNU-stack,"",@progbits
	.ident	"GCC: (GNU) 3.4.6 20060404 (Red Hat 3.4.6-4)"
