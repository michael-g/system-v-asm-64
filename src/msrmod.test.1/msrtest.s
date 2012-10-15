.section .rodata
.LdevicePath:
	.asciz	"/dev/msrdrv"
.LuopsFmt:
	.asciz	"UOPS_RETIRED.ALL %llu\n"


.section .text

.macro set_msr_io iop r_base r_idx ecx=$0 eax=$0 edx=$0
	movl	\iop, 0x10 * \r_idx + 0x00(\r_base)	# .op = MSR_WRITE
	movl	\ecx, 0x10 * \r_idx + 0x04(\r_base)	# .ecx = \r_ecx
	movl	\eax, 0x10 * \r_idx + 0x08(\r_base)	# .eax = \r_eax
	movl	\edx, 0x10 * \r_idx + 0x0c(\r_base)	# .edx = \r_edx
.endm

.macro rd_msr_io r_base r_idx ecx 
	set_msr_io $1 \r_base \r_idx \ecx
.endm

.macro wr_msr_io r_base r_idx ecx:req eax=$0 edx=$0
	set_msr_io $2 \r_base \r_idx \ecx \eax \edx
.endm

.macro wr_msr_stop r_base r_idx
	set_msr_io $3 \r_base \r_idx
.endm

.macro wr_msr_perf_fixed_ctr_ctrl r_base r_idx
	# eax:0x222 enable all 3 i7 FFnCs to count while CPL > 0
	wr_msr_io \r_base \r_idx $0x38d $0x222
.endm

.macro wr_msr_perf_global_ctrl_on r_base r_idx
	# eax:0x0f enable all four PMCs
	# edx:0x07 enable all three FFnCs
	wr_msr_io \r_base \r_idx $0x38f $0x03 $0x07
.endm

.macro wr_msr_perf_global_ctrl_off r_base r_idx
	wr_msr_io \r_base \r_idx $0x38f
.endm

	.globl _start
	.type _start,@STT_FUNC
_start:
	mov	%rsp, %rbp
	sub	$0x70, %rsp

	lea	.LdevicePath, %rdi
	call	open@PLT
	mov     %rax, %rdi
	cmp	$-1, %rax
	je	.Lexit

	wr_msr_perf_global_ctrl_on %rsp 0	# Enable counters
	wr_msr_io   %rsp 1 $0x186 $0x004101c2 	# UOPS_RETIRED.ALL PMC[0] +USR +EN
	wr_msr_io   %rsp 2 $0xc1		# zero IA32_PMC0
	wr_msr_stop %rsp 3

	rd_msr_io   %rsp 4 $0xc1 
	wr_msr_perf_global_ctrl_off %rsp 5
	wr_msr_stop %rsp 6

	mov     %eax, %ebx
	mov	%eax, %edi
	mov	$0xDF01, %esi		# Value of IOCTL_MSR_CMDS per GCC.i 57089
	mov	%rsp, %rdx
	
	call	ioctl@PLT

	mov	%ebx, %edi
	mov     $0xDF01, %esi
	lea	0x40(%rsp), %rdx

	call	ioctl@PLT

	lea	.LuopsFmt, %rdi
	mov	$1, %al
	movq	0x48(%rsp), %rsi

	call	printf@PLT
	
		


.LsuccessExit:
	xor	%rdi, %rdi
.Lexit:
	mov	$0x3c, %rax
	syscall
