.include "msrmacro.s"

.section .rodata
.LdevicePath:
	.asciz	"/dev/msrdrv"
.LuopsRetiredAllFmt:
	.asciz	"UOPS_RETIRED.ALL %llu\n"
.LinstrRetdAnyFmt:
	.asciz	"INSTR_RETIRED.ANY %llu\n"
.LcpuClkCoreFmt:
	.asciz	"CLU_CLK_UNHALTED.CORE %llu\n"
.LcpuClkRefFmt:
	.asciz	"CLU_CLK_UNHALTED.REF %llu\n"
.LuopsIssuedAnyFmt:
	.asciz	"UOPS_ISSUED.ANY %llu\n"
.LllcMissesFmt:
	.asciz	"LLC Misses %llu\n"
.Llvl1DataCacheMiss:
	.asciz	"L1 Data cache misses %llu\n"
.LelapsedTSC:
	.asciz	"Elapsed TSC ticks: %llu\n"

.section .text
	.globl _start
	.type _start,@STT_FUNC
_start:
	mov	%rsp, %rbp
	sub	$0x400, %rsp

	lea	.LdevicePath, %rdi
	call	open@PLT
	mov     %rax, %rdi
	cmp	$-1, %rax
	je	.Lexit
	
	movq	$0, 40 * 0x10 + 0x00(%rsp)
	movq	$0, 40 * 0x10 + 0x08(%rsp)
	movq	$0, 40 * 0x10 + 0x10(%rsp)
	movq	$0, 40 * 0x10 + 0x18(%rsp)
	movq	$0, 40 * 0x10 + 0x20(%rsp)
	movq	$0, 40 * 0x10 + 0x28(%rsp)
	movq	$0, 40 * 0x10 + 0x30(%rsp)
	movq	$0, 40 * 0x10 + 0x38(%rsp)

	wr_msr_stop %rsp 15			# Stop processing
	wr_msr_gpmc %rsp 14   $0x0f $0x07	# Enable PMCs and FFCs
	wr_msr_gffc %rsp 13   $0x0222		# Configure FFCs 
	wr_msr_pesx %rsp 12 3 $0x0041010e 	# Set PMC3 = UOPS_ISSUED.ANY  +USR +EN @ 3C:35-7/p241 3B:19-36/p252 0x0e:0x01
	wr_msr_pesx %rsp 11 2 $0x0041412e 	# Set PMC2 = LLC Misses       +USR +EN @ 3C:35-7/p241 3B:19-1 /p217 0x2e:0x41
	wr_msr_pesx %rsp 10 1 $0x00410f24 	# Set PMC1 = L1 Cache Misses  +USR +EN @ 3C:35-7/p241 3B:19-23/p239 0x24:0x08|0x04|0x03|0x01
	wr_msr_pesx %rsp  9 0 $0x004101c2 	# Set PMC0 = UOPS_RETIRED.ALL +USR +EN @ 3C:35-7/p241 3B:19-28/p244 0xc2:0x01
	wr_msr_ffcx %rsp  8 2			# zero FFC2 CPU_CLOCK_UNHALTED.REF
	wr_msr_ffcx %rsp  7 1			# zero FFC1 CPU_CLOCK_UNHALTED.CORE
	wr_msr_ffcx %rsp  6 0			# zero FFC0 INSTR_RETIRED.ANY
	wr_msr_pmcx %rsp  5 3			# zero IA32_PMC3
	wr_msr_pmcx %rsp  4 2			# zero IA32_PMC2
	wr_msr_pmcx %rsp  3 1			# zero IA32_PMC1
	wr_msr_pmcx %rsp  2 0			# zero IA32_PMC0
	rd_tsc      %rsp  1			# Read the TSC value
	wr_msr_gpmc %rsp  0			# Disable PMCs and FFCs prior to clear

	wr_msr_stop %rsp 33			# Stop processing
	wr_msr_ffcx %rsp 32 2			# zero FFC2 CPU_CLOCK_UNHALTED.REF
	wr_msr_ffcx %rsp 31 1			# zero FFC1 CPU_CLOCK_UNHALTED.CORE
	wr_msr_ffcx %rsp 30 0			# zero FFC0 INSTR_RETIRED.ANY
	wr_msr_pmcx %rsp 29 3			# zero IA32_PMC3
	wr_msr_pmcx %rsp 28 2			# zero IA32_PMC2
	wr_msr_pmcx %rsp 27 1			# zero IA32_PMC1
	wr_msr_pmcx %rsp 26 0			# zero IA32_PMC0
	rd_msr_ffcx %rsp 25 2			# Read FFC2 CPU_CLOCK_UNHALTED.REF
	rd_msr_ffcx %rsp 24 1			# Read FFC1 CPU_CLOCK_UNHALTED.CORE
	rd_msr_ffcx %rsp 23 0			# Read FFC0 INSTR_RETIRED.ANY
	rd_msr_pmcx %rsp 22 3	 		# Read IA32_PMC3 @ 3C:35-5 / UOPS_ISSUED.ANY
	rd_msr_pmcx %rsp 21 2	 		# Read IA32_PMC2 @ 3C:35-5 / LLC Misses
	rd_msr_pmcx %rsp 20 1	 		# Read IA32_PMC1 @ 3C:35-5 / L2_L1D_WB...
	rd_msr_pmcx %rsp 19 0			# Read IA32_PMC0 @ 3C:35-5 / UOPS_RETIRED.ALL
	rd_tsc      %rsp 18			# Read the TSC value
	wr_msr_gffc %rsp 17			# Clear FFCs control bits
	wr_msr_gpmc %rsp 16			# Disable PMCs and FFCs

	mov	$0x20, %r12
.LtimerLoopStart:
	mov     %eax, %ebx
	mov	%eax, %edi
	mov	$0xDF01, %esi			# Value of IOCTL_MSR_CMDS per GCC.i 57089
	mov	%rsp, %rdx
	call	ioctl@PLT

	mov	%ebx, %edi
	mov     $0xDF01, %esi
	lea	16 * 0x10(%rsp), %rdx
	call	ioctl@PLT

	movq	23 * 0x10 + 0x8(%rsp), %rsi
	addq	40 * 0x10 + 0x00(%rsp), %rsi
	movq	%rsi, 40 * 0x10 + 0x00(%rsp)

	movq	24 * 0x10 + 0x8(%rsp), %rsi
	addq	40 * 0x10 + 0x08(%rsp), %rsi
	movq	%rsi, 40 * 0x10 + 0x08(%rsp)

	movq	25 * 0x10 + 0x8(%rsp), %rsi
	addq	40 * 0x10 + 0x10(%rsp), %rsi
	movq	%rsi, 40 * 0x10 + 0x10(%rsp)

	movq	19 * 0x10 + 0x8(%rsp), %rsi
	addq	40 * 0x10 + 0x18(%rsp), %rsi
	movq	%rsi, 40 * 0x10 + 0x18(%rsp)

	movq	20 * 0x10 + 0x8(%rsp), %rsi
	addq	40 * 0x10 + 0x20(%rsp), %rsi
	movq	%rsi, 40 * 0x10 + 0x20(%rsp)

	movq	21 * 0x10 + 0x8(%rsp), %rsi
	addq	40 * 0x10 + 0x28(%rsp), %rsi
	movq	%rsi, 40 * 0x10 + 0x28(%rsp)

	movq	22 * 0x10 + 0x8(%rsp), %rsi
	addq	40 * 0x10 + 0x30(%rsp), %rsi
	movq	%rsi, 40 * 0x10 + 0x30(%rsp)

	movq	18 * 0x10 + 0x8(%rsp), %rsi
	subq	 1 * 0x10 + 0x8(%rsp), %rsi
	addq	40 * 0x10 + 0x38(%rsp), %rsi
	movq	%rsi, 40 * 0x10 + 0x38(%rsp)

	sub	$1, %r12
	jnz	.LtimerLoopStart

	mov	$0x20, %r12

	xor	%rdx, %rdx
	movq	40 * 0x10 + 0x00(%rsp), %rax
	div	%r12
	mov	%rax, %rsi
	lea	.LinstrRetdAnyFmt, %rdi
	mov	$1, %al
	call	printf@PLT

	xor	%rdx, %rdx
	movq	40 * 0x10 + 0x08(%rsp), %rax
	div	%r12
	mov	%rax, %rsi
	lea	.LcpuClkCoreFmt, %rdi
	mov	$1, %al
	call	printf@PLT

	xor	%rdx, %rdx
	movq	40 * 0x10 + 0x10(%rsp), %rax
	div	%r12
	mov	%rax, %rsi
	lea	.LcpuClkRefFmt, %rdi
	mov	$1, %al
	call	printf@PLT

	xor	%rdx, %rdx
	movq	40 * 0x10 + 0x18(%rsp), %rax
	div	%r12
	mov	%rax, %rsi
	lea	.LuopsRetiredAllFmt, %rdi
	mov	$1, %al
	call	printf@PLT

	xor	%rdx, %rdx
	movq	40 * 0x10 + 0x20(%rsp), %rax
	div	%r12
	mov	%rax, %rsi
	lea	.Llvl1DataCacheMiss, %rdi
	mov	$1, %al
	call	printf@PLT

	xor	%rdx, %rdx
	movq	40 * 0x10 + 0x28(%rsp), %rax
	div	%r12
	mov	%rax, %rsi
	lea	.LllcMissesFmt, %rdi
	mov	$1, %al
	call	printf@PLT

	xor	%rdx, %rdx
	movq	40 * 0x10 + 0x30(%rsp), %rax
	div	%r12
	mov	%rax, %rsi
	lea	.LuopsIssuedAnyFmt, %rdi
	mov	$1, %al
	call	printf@PLT

	xor	%rdx, %rdx
	movq	40 * 0x10 + 0x38(%rsp), %rax
	div	%r12
	mov	%rax, %rsi
	lea	.LelapsedTSC, %rdi
	mov	$1, %al
	call	printf@PLT

.LsuccessExit:
	xor	%rdi, %rdi
.Lexit:
	mov	$0x3c, %rax
	syscall
