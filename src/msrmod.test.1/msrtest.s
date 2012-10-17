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

.section .text

.macro set_msr_io iop r_base idx ecx=$0 eax=$0 edx=$0
	movl	\iop, 0x10 * \idx + 0x00(\r_base)	# .op = MSR_WRITE
	movl	\ecx, 0x10 * \idx + 0x04(\r_base)	# .ecx = \r_ecx
	movl	\eax, 0x10 * \idx + 0x08(\r_base)	# .eax = \r_eax
	movl	\edx, 0x10 * \idx + 0x0c(\r_base)	# .edx = \r_edx
.endm

.macro rd_msr_io r_base idx ecx 
	set_msr_io $1 \r_base \idx \ecx
.endm

.macro wr_msr_io r_base idx ecx:req eax=$0 edx=$0
	set_msr_io $2 \r_base \idx \ecx \eax \edx
.endm

.macro wr_msr_stop r_base idx
	set_msr_io $3 \r_base \idx
.endm

.macro wr_msr_perf_fixed_ctr_ctrl_on r_base idx		# IA32_FIXED_CTR_CTRL
	wr_msr_io \r_base \idx $0x38d $0x222		# 0x222 enable all 3 i7 FFnCs to count while CPL > 0
.endm

.macro wr_msr_perf_fixed_ctr_ctrl_off r_base idx	# IA32_FIXED_CTR_CTRL
	wr_msr_io \r_base \idx $0x38d $0x000		# disable enable all 3 i7 FFnCs to count while CPL > 0
.endm

.macro wr_msr_perf_global_ctrl_on r_base idx
	wr_msr_io \r_base \idx $0x38f $0x0f $0x07	# Image on 3B:18-36/p158. NotaBene low-DW hi-DW!!
.endm

.macro wr_msr_perf_global_ctrl_off r_base idx
	wr_msr_io \r_base \idx $0x38f
.endm

.macro wr_msr_ia32_fixed_ctr r_base idx ctr_idx eax=$0 edx=$0
.ifc \ctr_idx, 0
	wr_msr_io \r_base \idx $0x309 \eax \edx	# INSTR_RETIRED.ANY
.else
 .ifc \ctr_idx, 1
	wr_msr_io \r_base \idx $0x30a \eax \edx	# CPU_CLK_UNHALTED.CORE
 .else
  .ifc \ctr_idx, 2
	wr_msr_io \r_base \idx $0x30b \eax \edx	# CPU_CLK_UNHALTED.REF
  .else
	.warning "Unknown IA32_FIXED_CTRx"
  .endif
 .endif
.endif
.endm

.macro rd_msr_ia32_fixed_ctr r_base idx ctr_idx
.ifc \ctr_idx, 0
	rd_msr_io \r_base \idx $0x309		# INSTR_RETIRED.ANY
.else
 .ifc \ctr_idx, 1
	rd_msr_io \r_base \idx $0x30a		# CPU_CLK_UNHALTED.CORE
 .else
  .ifc \ctr_idx, 2
	rd_msr_io \r_base \idx $0x30b		# CPU_CLK_UNHALTED.REF
  .else
	.warning "Unknown IA32_FIXED_CTRx"
  .endif
 .endif
.endif
.endm
	.globl _start
	.type _start,@STT_FUNC
_start:
	mov	%rsp, %rbp
	sub	$0x300, %rsp

	lea	.LdevicePath, %rdi
	call	open@PLT
	mov     %rax, %rdi
	cmp	$-1, %rax
	je	.Lexit

	wr_msr_stop %rsp 15			# Stop
	wr_msr_perf_global_ctrl_on %rsp 14	# Enable PMC
	wr_msr_perf_fixed_ctr_ctrl_on %rsp 13	# Enable FFC
	wr_msr_io   %rsp 12 $0x189 $0x0041010e 	# Set PMC3 = UOPS_ISSUED.ANY           @ 3C:35-7/p241 3B:19-36/p252 0x0e:0x01
	wr_msr_io   %rsp 11 $0x188 $0x0041412e 	# Set PMC2 = LLC Misses                @ 3C:35-7/p241 3B:19-1 /p217 0x2e:0x41
	wr_msr_io   %rsp 10 $0x187 $0x00410f24 	# Set PMC1 = L1 Cache Misses           @ 3C:35-7/p241 3B:19-23/p239 0x24:0x08|0x04|0x03|0x01
	wr_msr_io   %rsp  9 $0x186 $0x004101c2 	# Set PMC0 = UOPS_RETIRED.ALL +USR +EN @ 3C:35-7/p241 3B:19-28/p244 0xc2:0x01
	wr_msr_ia32_fixed_ctr %rsp 8 2		# zero cpu_clock_unhalted.ref
	wr_msr_ia32_fixed_ctr %rsp 7 1		# zero cpu_clock_unhalted.core
	wr_msr_ia32_fixed_ctr %rsp 6 0		# zero instr_retired.any
	wr_msr_io   %rsp 5 $0xc4		# zero IA32_PMC0
	wr_msr_io   %rsp 4 $0xc3		# zero IA32_PMC0
	wr_msr_io   %rsp 3 $0xc2		# zero IA32_PMC0
	wr_msr_io   %rsp 2 $0xc1		# zero IA32_PMC0
	wr_msr_perf_fixed_ctr_ctrl_off %rsp 1	# Disable FFC prior to clear
	wr_msr_perf_global_ctrl_off %rsp 0	# Disable PMC prior to clear

	wr_msr_stop %rsp 32			# Stop
	wr_msr_ia32_fixed_ctr %rsp 31 2		# zero cpu_clock_unhalted.ref
	wr_msr_ia32_fixed_ctr %rsp 30 1		# zero cpu_clock_unhalted.core
	wr_msr_ia32_fixed_ctr %rsp 29 0		# zero instr_retired.any
	wr_msr_io   %rsp 28 $0xc4		# zero IA32_PMC0
	wr_msr_io   %rsp 27 $0xc3		# zero IA32_PMC0
	wr_msr_io   %rsp 26 $0xc2		# zero IA32_PMC0
	wr_msr_io   %rsp 25 $0xc1		# zero IA32_PMC0
	rd_msr_ia32_fixed_ctr %rsp 24 2		# Read cpu_clock_unhalted.ref
	rd_msr_ia32_fixed_ctr %rsp 23 1		# Read cpu_clock_unhalted.core
	rd_msr_ia32_fixed_ctr %rsp 22 0		# Read instr_retired.any
	rd_msr_io   %rsp 21 $0xc4 		# Read IA32_PMC3 @ 3C:35-5 / UOPS_ISSUED.ANY
	rd_msr_io   %rsp 20 $0xc3 		# Read IA32_PMC2 @ 3C:35-5 / LLC Misses
	rd_msr_io   %rsp 19 $0xc2 		# Read IA32_PMC1 @ 3C:35-5 / L2_L1D_WB...
	rd_msr_io   %rsp 18 $0xc1 		# Read IA32_PMC0 @ 3C:35-5 / UOPS_RETIRED.ALL
	wr_msr_perf_fixed_ctr_ctrl_off %rsp 17	# Disable FFC
	wr_msr_perf_global_ctrl_off %rsp 16	# Disable PMC

#	set_msr_io  $0 %rsp 12
#	set_msr_io  $0 %rsp 11
#	set_msr_io  $0 %rsp 10
#	set_msr_io  $0 %rsp 9
#	set_msr_io  $0 %rsp 16
#	set_msr_io  $0 %rsp 17
#	set_msr_io  $0 %rsp 18

	mov     %eax, %ebx
	mov	%eax, %edi
	mov	$0xDF01, %esi		# Value of IOCTL_MSR_CMDS per GCC.i 57089
	mov	%rsp, %rdx
	call	ioctl@PLT

	mov	%ebx, %edi
	mov     $0xDF01, %esi
	lea	16 * 0x10(%rsp), %rdx
	call	ioctl@PLT

	lea	.LinstrRetdAnyFmt, %rdi
	mov	$1, %al
	movq	22 * 0x10 + 0x8(%rsp), %rsi
	call	printf@PLT
		
	lea	.LcpuClkCoreFmt, %rdi
	mov	$1, %al
	movq	23 * 0x10 + 0x8(%rsp), %rsi
	call	printf@PLT
	
	lea	.LcpuClkRefFmt, %rdi
	mov	$1, %al
	movq	24 * 0x10 + 0x8(%rsp), %rsi
	call	printf@PLT
		
	lea	.LuopsRetiredAllFmt, %rdi
	mov	$1, %al
	movq	18 * 0x10 + 0x8(%rsp), %rsi
	call	printf@PLT

	lea	.Llvl1DataCacheMiss, %rdi
	mov	$1, %al
	movq	19 * 0x10 + 0x8(%rsp), %rsi
	call	printf@PLT

	lea	.LllcMissesFmt, %rdi
	mov	$1, %al
	movq	20 * 0x10 + 0x8(%rsp), %rsi
	call	printf@PLT

	lea	.LuopsIssuedAnyFmt, %rdi
	mov	$1, %al
	movq	21 * 0x10 + 0x8(%rsp), %rsi
	call	printf@PLT

		

.LsuccessExit:
	xor	%rdi, %rdi
.Lexit:
	mov	$0x3c, %rax
	syscall
