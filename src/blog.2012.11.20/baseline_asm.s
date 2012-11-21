# (c) Michael Guyver, 2012, all rights reserved. Permission to use, copy, modify and distribute the 
# software is hereby granted for educational use which is non-commercial in nature, provided that 
# this copyright  notice and following two paragraphs are included in all copies, modifications and 
# distributions.
#
# THIS SOFTWARE AND DOCUMENTATION IS PROVIDED "AS IS," AND NO REPRESENTATIONS OR WARRANTIES ARE 
# MADE, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO, WARRANTIES OF MERCHANTABILITY OR 
# FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE SOFTWARE OR DOCUMENTATION WILL NOT 
# INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
#
# COPYRIGHT HOLDERS WILL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL OR CONSEQUENTIAL DAMAGES 
# ARISING OUT OF ANY USE OF THE SOFTWARE OR DOCUMENTATION.

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
