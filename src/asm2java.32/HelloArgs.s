	.file	"HelloArgs.c"
	.section	.rodata
.LC0:
	.string	"HelloArgs"
.LC1:
	.string	"()V"
.LC2:
	.string	"printMessage"
	.text
.globl Java_HelloArgs_sayHello
	.type	Java_HelloArgs_sayHello, @function
Java_HelloArgs_sayHello:
.LFB2:
	pushq	%rbp
.LCFI0:
	movq	%rsp, %rbp
.LCFI1:
	subq	$32, %rsp
.LCFI2:
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movq	-8(%rbp), %rax
	movq	(%rax), %rax
	movq	-8(%rbp), %rdi
	movq	48(%rax), %rax
	leaq	.LC0(%rip), %rsi
	call	*%rax
	movq	%rax, -24(%rbp)
	movq	-8(%rbp), %rax
	movq	(%rax), %rax
	movq	-24(%rbp), %rsi
	movq	-8(%rbp), %rdi
	movq	264(%rax), %rax
	leaq	.LC1(%rip), %rcx
	leaq	.LC2(%rip), %rdx
	call	*%rax
	movq	%rax, -32(%rbp)
	movq	-8(%rbp), %rax
	movq	(%rax), %rax
	movq	-32(%rbp), %rdx
	movq	-16(%rbp), %rsi
	movq	-8(%rbp), %rdi
	movq	488(%rax), %rcx
	movl	$0, %eax
	call	*%rcx
	leave
	ret
.LFE2:
	.size	Java_HelloArgs_sayHello, .-Java_HelloArgs_sayHello
.globl Java_HelloArgs_multiply
	.type	Java_HelloArgs_multiply, @function
Java_HelloArgs_multiply:
.LFB3:
	pushq	%rbp
.LCFI3:
	movq	%rsp, %rbp
.LCFI4:
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movl	%edx, -20(%rbp)
	movq	%rcx, -32(%rbp)
	movq	%r8, -40(%rbp)
	leave
	ret
.LFE3:
	.size	Java_HelloArgs_multiply, .-Java_HelloArgs_multiply
	.section	.eh_frame,"a",@progbits
.Lframe1:
	.long	.LECIE1-.LSCIE1
.LSCIE1:
	.long	0x0
	.byte	0x1
	.string	"zR"
	.uleb128 0x1
	.sleb128 -8
	.byte	0x10
	.uleb128 0x1
	.byte	0x1b
	.byte	0xc
	.uleb128 0x7
	.uleb128 0x8
	.byte	0x90
	.uleb128 0x1
	.align 8
.LECIE1:
.LSFDE1:
	.long	.LEFDE1-.LASFDE1
.LASFDE1:
	.long	.LASFDE1-.Lframe1
	.long	.LFB2-.
	.long	.LFE2-.LFB2
	.uleb128 0x0
	.byte	0x4
	.long	.LCFI0-.LFB2
	.byte	0xe
	.uleb128 0x10
	.byte	0x86
	.uleb128 0x2
	.byte	0x4
	.long	.LCFI1-.LCFI0
	.byte	0xd
	.uleb128 0x6
	.align 8
.LEFDE1:
.LSFDE3:
	.long	.LEFDE3-.LASFDE3
.LASFDE3:
	.long	.LASFDE3-.Lframe1
	.long	.LFB3-.
	.long	.LFE3-.LFB3
	.uleb128 0x0
	.byte	0x4
	.long	.LCFI3-.LFB3
	.byte	0xe
	.uleb128 0x10
	.byte	0x86
	.uleb128 0x2
	.byte	0x4
	.long	.LCFI4-.LCFI3
	.byte	0xd
	.uleb128 0x6
	.align 8
.LEFDE3:
	.section	.note.GNU-stack,"",@progbits
	.ident	"GCC: (GNU) 3.4.6 20060404 (Red Hat 3.4.6-4)"
