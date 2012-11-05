.include "savereg.macro.s"

.section .text
	.globl	execute_baseline
	.type	execute_baseline, STT_FUNC
# void execute_baseline(
#       int times,
#       void (start_counters)(void),
#       void (stop_counters)(void)
# );
execute_baseline:
	push	%rbp
	cmp	$0, %rdi
	je	.LloopEnd
.LloopStart:
	m_save_regs
	call	*%rsi
	m_restore_regs
	m_save_regs
	call	*%rdx
	m_restore_regs
	sub	$1, %rdi
	jg	.LloopStart

.LloopEnd:
	popq	%rbp
	ret
