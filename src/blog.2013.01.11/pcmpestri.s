.section .text

.globl main
.type main, STT_FUNC

main:

	mov       %rsp, %rbp
	sub       $0x100, %rsp
	and       $~0xf, %rsp
	mov       $0x100, %rcx
	xor       %rax, %rax
.L0:
	mov       %rax, (%rsp, %rax, 1)
	add       $0x01, %rax
	cmp       %rax, %rcx
	jne       .L0

	movdqa    (%rsp), %xmm0
#	movl      $0x00, 12(%rsp)
	movb      $0x00, 12(%rsp)
	movdqa    (%rsp), %xmm1
	# -------0b 128-bit sources treated as 16 packed bytes.
	# -------1b 128-bit sources treated as 8 packed words.
	# ------0-b Packed bytes/words are unsigned.
	# ------1-b Packed bytes/words are signed.
	# ----00--b Mode is equal any.
	# ----01--b Mode is ranges.
	# ----10--b Mode is equal each.
	# ----11--b Mode is equal ordered.
	# ---0----b IntRes1 is unmodified.
	# ---1----b IntRes1 is negated (1’s compliment).
	# --0-----b Negation of IntRes1 is for all 16 (8) bits.
	# --1-----b Negation of IntRes1 is masked by reg/mem validity.
	# -0------b Index of the least significant, set, bit is used (regardless of corresponding
	#           input element validity).
	#           IntRes2 is returned in least significant bits of XMM0.
	# -1------b Index of the most significant, set, bit is used (regardless of corresponding
	#           input element validity).
	#           Each bit of IntRes2 is expanded to byte/word.
	# 0-------b This bit currently has no defined effect, should be 0.
	# 1-------b This bit currently has no defined effect, should be 0.

	# 01001000
	
	mov       $0x10, %rax
	mov       $0x10, %rdx
	pcmpestri $0x18, (%rsp), %xmm0

