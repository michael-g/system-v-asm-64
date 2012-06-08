.section .data
msgfmt:
	.ascii	"input:  st(0): %.1f\n"
	.ascii	"        st(1): %.1f\n"
	.ascii	"instr:  %s\n"
	.ascii	"output: st(0): %.1f\n"
	.asciz	"        st(1): %.1f\n\n"
s_subst0st1:
	.asciz	"fsub	%st(0), %st(1)"
s_subst1st0:
	.asciz	"fsub	%st(1), %st(0)"
s_subrst0st1:
	.asciz	"fsubr	%st(0), %st(1)"
s_subrst1st0:
	.asciz	"fsubr	%st(1), %st(0)"

st0:
	.double	5.0
st1:
	.double 7.0

.section .bss
.lcomm	result, 0x8

.section .text
.globl	_start
_start:

	nop
	lea     fsubst0st1, %rdi
	call    finvoker

	lea     fsubst1st0, %rdi
	call    finvoker
	
	lea     fsubrst0st1, %rdi
	call    finvoker

	lea     fsubrst1st0, %rdi
	call    finvoker

	xor     %rdi, %rdi
	call	exit

fsubst0st1:
	fsub    %st(0), %st(1)
	lea	s_subst0st1, %rsi
	ret

fsubst1st0:
	fsub    %st(1), %st(0)
	lea     s_subst1st0, %rsi
	ret

fsubrst0st1:
	fsubr   %st(0), %st(1)
	lea     s_subrst0st1, %rsi
	ret

fsubrst1st0:
	fsubr   %st(1), %st(0)
	lea     s_subrst1st0, %rsi
	ret

finvoker:
	push    %rbp		# Store base-pointer
	and     $~0xF, %rsp	# Align stack-pointer for call to printf

	finit
	fldl    st1		# Push value at st1 onto FP stack
	fldl    st0		# Push value at st0 onto FP stack
	call    *%rdi		# Invoke function pointer
	movsd   st0, %xmm0	# Copy value at st0 to XMM0
	movsd   st1, %xmm1	# Copy value at st1 to XMM1
	
	fstpl   result		# Copy st(0) to result0 and pop FP stack
	movsd	result, %xmm2	# Copy value from FP stack to XMM2
	fstpl   result		# Repeat for next top-of-stack
	movsd   result, %xmm3	# Copy value to XMM3

	lea     msgfmt, %rdi	# Load address of msgfmt into RDI
	mov     $0x5, %al	# Set varargs-count in AL
	call    printf		# 
	pop     %rbp		# Restore base pointer prior to return
	ret

