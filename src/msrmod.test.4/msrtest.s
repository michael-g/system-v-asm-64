.include "msrmacro.s"

.section .rodata
.LdevicePath:
	.asciz	"/dev/msrdrv"
.LPmc0Fmt:
	.asciz	"PMC0: UOPS_RETIRED.ALL      %9llu\n"
.LPmc1Fmt:
	.asciz	"PMC1: UOPS_ISSUED.ANY       %9llu\n"
.LPmc2Fmt:
	.asciz	"PMC2: L1 Data cache misses  %9llu\n"
.LPmc3Fmt:
	.asciz	"PMC3: LLC Misses            %9llu\n"
.LFfc0Fmt:
	.asciz	"FFC0: INSTR_RETIRED.ANY     %9llu\n"
.LFfc1Fmt:
	.asciz	"FFC1: CPU_CLK_UNHALTED.CORE %9llu\n"
.LFfc2Fmt:
	.asciz	"FFC2: CPU_CLK_UNHALTED.REF  %9llu\n"
.LElapsedTSC:
	.asciz	"Elapsed TSC ticks:          %9llu\n"

.section .data

.align 0x40
.LresetMsrScript:
	mem_wr_gpmc 			# Disable PMCs and FFCs prior to clear
	mem_wr_pmcx 0			# zero IA32_PMC0
	mem_wr_pmcx 1			# zero IA32_PMC1
	mem_wr_pmcx 2			# zero IA32_PMC2
	mem_wr_pmcx 3			# zero IA32_PMC3
	mem_wr_ffcx 0			# zero FFC0 INSTR_RETIRED.ANY
	mem_wr_ffcx 1			# zero FFC1 CPU_CLOCK_UNHALTED.CORE
	mem_wr_ffcx 2			# zero FFC2 CPU_CLOCK_UNHALTED.REF
	mem_wr_pesx 0 0x004101c2 	# Set PMC0 = UOPS_RETIRED.ALL +USR +EN @ 3C:35-7/p241 3B:19-28/p244 0xc2:0x01
	mem_wr_pesx 1 0x0041010e 	# Set PMC3 = UOPS_ISSUED.ANY  +USR +EN @ 3C:35-7/p241 3B:19-36/p252 0x0e:0x01
	mem_wr_pesx 2 0x00410f24 	# Set PMC1 = L1 Cache Misses  +USR +EN @ 3C:35-7/p241 3B:19-23/p239 0x24:0x08|0x04|0x03|0x01
	mem_wr_pesx 3 0x0041412e 	# Set PMC2 = LLC Misses       +USR +EN @ 3C:35-7/p241 3B:19-1 /p217 0x2e:0x41
.LTscRead0:
	mem_rd_tsc			# Read the TSC value
	mem_wr_gffc   0x0222		# Configure FFCs 
	mem_wr_gpmc   0x0f 0x07		# Enable PMCs and FFCs
	mem_stop			# End-of-script

.align 0x40
.LreadMsrValues:
	mem_wr_gpmc			# Disable PMCs and FFCs
	mem_wr_gffc			# Clear FFCs control bits
.LTscRead1:
	mem_rd_tsc			# Read the TSC value
.LPmc0Read:
	mem_rd_pmcx 0			# Read IA32_PMC0 @ 3C:35-5 / UOPS_RETIRED.ALL
.LPmc1Read:
	mem_rd_pmcx 1	 		# Read IA32_PMC1 @ 3C:35-5 / L2_L1D_WB...
.LPmc2Read:
	mem_rd_pmcx 2	 		# Read IA32_PMC2 @ 3C:35-5 / LLC Misses
.LPmc3Read:
	mem_rd_pmcx 3	 		# Read IA32_PMC3 @ 3C:35-5 / UOPS_ISSUED.ANY
.LFfc0Read:
	mem_rd_ffcx 0			# Read FFC0 INSTR_RETIRED.ANY
.LFfc1Read:
	mem_rd_ffcx 1			# Read FFC1 CPU_CLOCK_UNHALTED.CORE
.LFfc2Read:
	mem_rd_ffcx 2			# Read FFC2 CPU_CLOCK_UNHALTED.REF
	mem_stop			# End-of-script

.section .bss
	.lcomm	.LPmc0Latency, 8
	.lcomm	.LPmc1Latency, 8
	.lcomm	.LPmc2Latency, 8
	.lcomm	.LPmc3Latency, 8
	.lcomm	.LFfc0Latency, 8
	.lcomm	.LFfc1Latency, 8
	.lcomm	.LFfc2Latency, 8
	.lcomm	.LTscLatency,  8

.section .text
	.globl accumulate
accumulate:
.LaccumulateCounter:
	movq	0x08(%rdi), %rax	# Load cum. value from ptr + offset
	addq	%rax, (%rsi)		# Add value to accumulator
	ret

.LcalcAvgLatency:
	movq	(%rdi), %rax		# Load cumulative value from param[0] ptr
	mov	%dl, %cl		# Copy param[2] to reg for SHR
	shr	%cl, %rax		# Divide by 2expN
	movq	%rax, (%rsi)		# Store to param[1] ptr
	ret

.LprintCounter:
	mov	$1, %al
	jmp	printf@PLT


	.globl _start
	.type _start,@STT_FUNC
_start:
	mov	%rsp, %rbp
	sub	$0x60, %rsp
	
	# Zero the stack for future calcs
	mov	%rbp, %rax		# Copy RBP
	sub	%rsp, %rax		# Calc stack-reservation bytes
	shr	$3, %rax		# Div by 8, calc num QW
.LzeroStack:
	movq	$0, (%rsp,%rax,8)	# Move QW 0 to RSP+RAX*8
	sub	$1, %rax		# Decrement counter
	jge	.LzeroStack		# Loop if not zero

	# Open the fd for /dev/msrdrv
	lea	.LdevicePath, %rdi	# Load address of "/dev/msrdrv"
	call	open@PLT		# Call open
	mov     %rax, %rdi		# Copy result to RDI
	cmp	$-1, %rax		# Test result-code
	je	.Lexit			#    Early bath if it's -1

	mov     %eax, %ebx		# Copy fd to non-vol reg
	mov	$0x20, %r12		# Set loop counter
.LtimerLoopStart:
	mov	%eax, %edi		# Copy fd to param[0]
	mov	$0xDF01, %esi		# Set value of IOCTL_MSR_CMDS on param[1]
	lea	.LresetMsrScript, %rdx	# Set address of reset-script as param[2]
	call	ioctl@PLT

	mov	%ebx, %edi		# Copy fd to param[0]
	mov     $0xDF01, %esi		# Set IOCTL magic number, param[1]
	lea	.LreadMsrValues, %rdx	# Set address of read-script as param[2]
	call	ioctl@PLT

	lea	.LPmc0Read, %rdi
	lea	0x00(%rsp), %rsi
	call	.LaccumulateCounter

	lea	.LPmc1Read, %rdi
	lea	0x08(%rsp), %rsi
	call	.LaccumulateCounter

	lea	.LPmc2Read, %rdi
	lea	0x10(%rsp), %rsi
	call	.LaccumulateCounter

	lea	.LPmc3Read, %rdi
	lea	0x18(%rsp), %rsi
	call	.LaccumulateCounter

	lea	.LFfc0Read, %rdi
	lea	0x20(%rsp), %rsi
	call	.LaccumulateCounter

	lea	.LFfc1Read, %rdi
	lea	0x28(%rsp), %rsi
	call	.LaccumulateCounter

	lea	.LFfc2Read, %rdi
	lea	0x30(%rsp), %rsi
	call	.LaccumulateCounter
	
	mov	.LTscRead1 + 0x08, %rdi
	mov	.LTscRead0 + 0x08, %rsi
	sub	%rsi, %rdi
	mov	%rdi, 0x38(%rsp)

	sub	$1, %r12			# Decrement loop counter
	jnz	.LtimerLoopStart		# End loop

	mov	%rsp, %rdi
	lea	.LPmc0Latency, %rsi
	mov	$5, %dl
	call	.LcalcAvgLatency

	lea	0x08(%rsp), %rdi
	lea	.LPmc1Latency, %rsi
	mov	$5, %dl
	call	.LcalcAvgLatency

	lea	0x10(%rsp), %rdi
	lea	.LPmc2Latency, %rsi
	mov	$5, %dl
	call	.LcalcAvgLatency

	lea	0x18(%rsp), %rdi
	lea	.LPmc3Latency, %rsi
	mov	$5, %dl
	call	.LcalcAvgLatency

	lea	0x20(%rsp), %rdi
	lea	.LFfc0Latency, %rsi
	mov	$5, %dl
	call	.LcalcAvgLatency

	lea	0x28(%rsp), %rdi
	lea	.LFfc1Latency, %rsi
	mov	$5, %dl
	call	.LcalcAvgLatency

	lea	0x30(%rsp), %rdi
	lea	.LFfc2Latency, %rsi
	mov	$5, %dl
	call	.LcalcAvgLatency

	lea	0x38(%rsp), %rdi
	lea	.LTscLatency, %rsi
	mov	$5, %dl
	call	.LcalcAvgLatency

	lea	.LPmc0Fmt, %rdi
	mov	.LPmc0Latency, %rsi
	call	.LprintCounter

	lea	.LPmc1Fmt, %rdi
	mov	.LPmc1Latency, %rsi
	call	.LprintCounter

	lea	.LPmc2Fmt, %rdi
	mov	.LPmc2Latency, %rsi
	call	.LprintCounter

	lea	.LPmc3Fmt, %rdi
	mov	.LPmc3Latency, %rsi
	call	.LprintCounter

	lea	.LFfc0Fmt, %rdi
	mov	.LFfc0Latency, %rsi
	call	.LprintCounter

	lea	.LFfc1Fmt, %rdi
	mov	.LFfc1Latency, %rsi
	call	.LprintCounter

	lea	.LFfc2Fmt, %rdi
	mov	.LFfc2Latency, %rsi
	call	.LprintCounter

	lea	.LElapsedTSC, %rdi
	mov	.LTscLatency, %rsi
	call	.LprintCounter

.LsuccessExit:
	xor	%rdi, %rdi
.Lexit:
	mov	$0x3c, %rax
	syscall
