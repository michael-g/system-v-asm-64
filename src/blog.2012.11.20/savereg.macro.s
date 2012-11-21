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

.macro m_save_regs
	movaps    %xmm0, -0x10(%rsp)
	movaps    %xmm1, -0x20(%rsp)
	movaps    %xmm2, -0x30(%rsp)
	movaps    %xmm3, -0x40(%rsp)
	movq      %rax,  -0x48(%rsp)
	movq      %rbx,  -0x50(%rsp)
	movq      %rcx,  -0x58(%rsp)
	movq      %rdx,  -0x60(%rsp)
	movq      %rdi,  -0x68(%rsp)
	movq      %rsi,  -0x70(%rsp)
	movq      %r8,   -0x78(%rsp)
	movq      %r9,   -0x80(%rsp)
	movq      %r12,  -0x88(%rsp)
	movq      %r13,  -0x90(%rsp)
	movq      %r14,  -0x98(%rsp)
	movq      %r15,  -0xa0(%rsp)
	sub       $0xa0, %rsp
.endm

.macro m_restore_regs
	add       $0xa0, %rsp
	movq      -0xa0(%rsp), %r15
	movq      -0x98(%rsp), %r14
	movq      -0x90(%rsp), %r13
	movq      -0x88(%rsp), %r12
	movq      -0x80(%rsp), %r9
	movq      -0x78(%rsp), %r8
	movq      -0x70(%rsp), %rsi
	movq      -0x68(%rsp), %rdi
	movq      -0x60(%rsp), %rdx
	movq      -0x58(%rsp), %rcx
	movq      -0x50(%rsp), %rbx
	movq      -0x48(%rsp), %rax
	movaps    -0x40(%rsp), %xmm3
	movaps    -0x30(%rsp), %xmm2
	movaps    -0x20(%rsp), %xmm1
	movaps    -0x10(%rsp), %xmm0
.endm
