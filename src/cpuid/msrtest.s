	.file	"msrtest.c"
	.text
.Ltext0:
	.section	.rodata
.LC0:
	.string	"/dev/cpu/1/msr"
	.string	""
.LC1:
	.string	"Failed to open MSR"
.LC2:
	.string	"Failed to open %s\n"
.LC3:
	.string	"Successfully opened %s\n"
.LC4:
	.string	"While reading 0xCE"
	.align 8
.LC5:
	.string	"Value returned for pread at offset 0xCE is %Lx\n"
.LC6:
	.string	"Current frequency is %hhd\n"
.LC7:
	.string	"While reading IA32_MPERF"
.LC8:
	.string	"IA32_MPERF (0xE7) is %Ld\n"
.LC9:
	.string	"IA32_MPERF (0xE8) is %Ld\n"
.LC10:
	.string	"While closing FD"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.file 1 "msrtest.c"
	.loc 1 14 0
	.cfi_startproc
	pushq	%rbp
.LCFI0:
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
.LCFI1:
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	.loc 1 15 0
	movq	$.LC0, -16(%rbp)
	.loc 1 18 0
	movq	-16(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	open
	movl	%eax, -8(%rbp)
	.loc 1 19 0
	cmpl	$0, -8(%rbp)
	jns	.L2
	.loc 1 20 0
	movl	$.LC1, %edi
	call	perror
	.loc 1 21 0
	movl	$.LC2, %eax
	movq	-16(%rbp), %rdx
	movq	%rdx, %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf
	.loc 1 22 0
	movl	$-1, %eax
	jmp	.L3
.L2:
	.loc 1 24 0
	movl	$.LC3, %eax
	movq	-16(%rbp), %rdx
	movq	%rdx, %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf
	.loc 1 25 0
	leaq	-24(%rbp), %rsi
	movl	-8(%rbp), %eax
	movl	$206, %ecx
	movl	$8, %edx
	movl	%eax, %edi
	call	pread
	movl	%eax, -4(%rbp)
	.loc 1 26 0
	cmpl	$0, -4(%rbp)
	jns	.L4
	.loc 1 26 0 is_stmt 0 discriminator 1
	movl	$.LC4, %edi
	call	perror
	movl	$1, %eax
	jmp	.L3
.L4:
	.loc 1 28 0 is_stmt 1
	movq	-24(%rbp), %rdx
	movl	$.LC5, %eax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf
	.loc 1 29 0
	movq	-24(%rbp), %rax
	shrq	$8, %rax
	movzbl	%al, %edx
	movl	$.LC6, %eax
	movl	%edx, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf
	.loc 1 31 0
	leaq	-24(%rbp), %rsi
	movl	-8(%rbp), %eax
	movl	$231, %ecx
	movl	$8, %edx
	movl	%eax, %edi
	call	pread
	movl	%eax, -4(%rbp)
	.loc 1 32 0
	cmpl	$0, -4(%rbp)
	jns	.L5
	.loc 1 32 0 is_stmt 0 discriminator 1
	movl	$.LC7, %edi
	call	perror
	movl	$1, %eax
	jmp	.L3
.L5:
	.loc 1 33 0 is_stmt 1
	movq	-24(%rbp), %rdx
	movl	$.LC8, %eax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf
	.loc 1 35 0
	leaq	-24(%rbp), %rsi
	movl	-8(%rbp), %eax
	movl	$232, %ecx
	movl	$8, %edx
	movl	%eax, %edi
	call	pread
	movl	%eax, -4(%rbp)
	.loc 1 36 0
	cmpl	$0, -4(%rbp)
	jns	.L6
	.loc 1 36 0 is_stmt 0 discriminator 1
	movl	$.LC7, %edi
	call	perror
	movl	$1, %eax
	jmp	.L3
.L6:
	.loc 1 37 0 is_stmt 1
	movq	-24(%rbp), %rdx
	movl	$.LC9, %eax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf
	.loc 1 39 0
	movl	-8(%rbp), %eax
	movl	%eax, %edi
	call	close
	movl	%eax, -4(%rbp)
	.loc 1 40 0
	cmpl	$0, -4(%rbp)
	jns	.L7
	.loc 1 41 0
	movl	$.LC10, %edi
	call	perror
.L7:
	.loc 1 43 0
	movl	-4(%rbp), %eax
.L3:
	.loc 1 44 0
	leave
.LCFI2:
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
.Letext0:
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0xd4
	.value	0x2
	.long	.Ldebug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.long	.LASF12
	.byte	0x1
	.long	.LASF13
	.long	.LASF14
	.quad	.Ltext0
	.quad	.Letext0
	.long	.Ldebug_line0
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.long	.LASF0
	.uleb128 0x2
	.byte	0x1
	.byte	0x8
	.long	.LASF1
	.uleb128 0x2
	.byte	0x2
	.byte	0x7
	.long	.LASF2
	.uleb128 0x2
	.byte	0x4
	.byte	0x7
	.long	.LASF3
	.uleb128 0x2
	.byte	0x1
	.byte	0x6
	.long	.LASF4
	.uleb128 0x2
	.byte	0x2
	.byte	0x5
	.long	.LASF5
	.uleb128 0x3
	.byte	0x4
	.byte	0x5
	.string	"int"
	.uleb128 0x2
	.byte	0x8
	.byte	0x5
	.long	.LASF6
	.uleb128 0x4
	.byte	0x8
	.long	0x6b
	.uleb128 0x2
	.byte	0x1
	.byte	0x6
	.long	.LASF7
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.long	.LASF8
	.uleb128 0x2
	.byte	0x8
	.byte	0x5
	.long	.LASF9
	.uleb128 0x5
	.byte	0x1
	.long	.LASF15
	.byte	0x1
	.byte	0xd
	.byte	0x1
	.long	0x57
	.quad	.LFB0
	.quad	.LFE0
	.long	.LLST0
	.uleb128 0x6
	.long	.LASF10
	.byte	0x1
	.byte	0xf
	.long	0x65
	.byte	0x2
	.byte	0x91
	.sleb128 -32
	.uleb128 0x7
	.string	"e"
	.byte	0x1
	.byte	0x10
	.long	0x57
	.byte	0x2
	.byte	0x91
	.sleb128 -20
	.uleb128 0x7
	.string	"fd"
	.byte	0x1
	.byte	0x10
	.long	0x57
	.byte	0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x6
	.long	.LASF11
	.byte	0x1
	.byte	0x11
	.long	0x72
	.byte	0x2
	.byte	0x91
	.sleb128 -40
	.byte	0
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x1
	.uleb128 0x10
	.uleb128 0x6
	.byte	0
	.byte	0
	.uleb128 0x2
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.byte	0
	.byte	0
	.uleb128 0x4
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0xc
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0xc
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x1
	.uleb128 0x40
	.uleb128 0x6
	.byte	0
	.byte	0
	.uleb128 0x6
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0xa
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0xa
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_loc,"",@progbits
.Ldebug_loc0:
.LLST0:
	.quad	.LFB0-.Ltext0
	.quad	.LCFI0-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 8
	.quad	.LCFI0-.Ltext0
	.quad	.LCFI1-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 16
	.quad	.LCFI1-.Ltext0
	.quad	.LCFI2-.Ltext0
	.value	0x2
	.byte	0x76
	.sleb128 16
	.quad	.LCFI2-.Ltext0
	.quad	.LFE0-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 8
	.quad	0
	.quad	0
	.section	.debug_aranges,"",@progbits
	.long	0x2c
	.value	0x2
	.long	.Ldebug_info0
	.byte	0x8
	.byte	0
	.value	0
	.value	0
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.quad	0
	.quad	0
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF9:
	.string	"long long int"
.LASF3:
	.string	"unsigned int"
.LASF12:
	.string	"GNU C 4.6.3"
.LASF10:
	.string	"path"
.LASF15:
	.string	"main"
.LASF0:
	.string	"long unsigned int"
.LASF8:
	.string	"long long unsigned int"
.LASF11:
	.string	"freq"
.LASF1:
	.string	"unsigned char"
.LASF7:
	.string	"char"
.LASF6:
	.string	"long int"
.LASF13:
	.string	"msrtest.c"
.LASF14:
	.string	"/home/michaelg/dev/asm-git/src/cpuid"
.LASF2:
	.string	"short unsigned int"
.LASF4:
	.string	"signed char"
.LASF5:
	.string	"short int"
	.ident	"GCC: (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3"
	.section	.note.GNU-stack,"",@progbits
