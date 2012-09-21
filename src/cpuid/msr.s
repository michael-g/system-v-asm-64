.section .data
.LlevelTypeFmt:
	.asciz	"Level type: %hhd\n"
.LdevCpuStr:
	.ascii	"/dev/cpu/"
.LdevCpuStrLen:
	.int	. - .LdevCpuStr
.LmsrStr:
	.asciz	"/msr"
.LmsrStrLen:
	.int	. - .LmsrStr
.Lperror:
	.asciz	"Result code"
.LprintQuadFmt:
	.asciz	"MSR hex-Value is %Lx\n"
.LprintCpuSpeedFmt:
	.asciz	"CPU Speed is %Ld Hz\n"

.section .text
	.globl _start
_start:
	mov	%rsp, %rbp		# Store RBP (probably zero anyway)
	sub	$0x30, %rsp
	and	$~0x1f, %rsp		# Set up stack
	
	mov	$0x0b, %eax		# Request CPUID leaf 0x0B
	mov	$0x02, %ecx		# Set parameter in ECX (Core=2)
	cpuid
	
	shr	$0x8, %ecx		# Bits 15:8 contain 'Level Type'
	mov	%ecx, %r12d		# Save in non-vol register
	mov	%ecx, %esi		# Set param[1]
	lea	.LlevelTypeFmt, %rdi	# Set param[0]
	movb	$0x01, %al		# Set varargs count
	call	printf@PLT		# Call printf

	cld	          		# Clear direction flag (increments)
	movl	.LdevCpuStrLen, %ecx	# Store count in ECX
	mov	%rsp, %rdi		# Store dest in RDI
	leaq	.LdevCpuStr, %rsi	# Store src in RSI
rep 	movsb	          		# Copy bytes to Stack

	mov	$0x30, %eax		# Store ASCII for '0' (zero)
	add	%r12d, %eax		# Add value for Core ID
	movl	.LdevCpuStrLen, %edx
	mov	%edx, %edx
	lea     (%rsp, %rdx), %rcx
	movb	%al, (%rcx)
					# Store single digit CPU ID to stack as ASCII

	movl	.LmsrStrLen, %ecx	# Store count in ECX
	lea	0x01(%rsp,%rdx), %rdi	# Store dest in RDI
	leaq	.LmsrStr, %rsi		# Store src in RSI
rep 	movsb	          		# Copy bytes to Stack

	mov	%rsp, %rdi
	call	puts@PLT

	mov	%rsp, %rdi
	xor	%esi, %esi
	call	open@PLT

	mov	%eax, %r12d
	mov	%rsp, %rdi
	call	perror@PLT

	mov	%r12d, %edi
	mov	%rsp, %rsi
	mov	$0x08, %rdx
	mov	$0xCE, %rcx
	call	pread@PLT

	mov	%eax, %esi
	lea	.Lperror, %rdi
	call	perror@PLT

	movq	(%rsp), %rsi
	lea	.LprintQuadFmt, %rdi
	mov	$0x01, %al
	call	printf@PLT

	movq	(%rsp), %rdi
	shr	$0x08, %rdi
	and	$0xFF, %rdi
	mov	$0x5f5e100, %eax
	mul	%edi

	shr	$0x20, %rdx
	mov	%eax, %eax
	or      %rdx, %rax
	mov	%rax, %rsi
	
	lea	.LprintCpuSpeedFmt, %rdi
	mov	$0x01, %al
	call	printf@PLT

	mov	$0x3c, %rax
	xor	%rdi, %rdi
	syscall
