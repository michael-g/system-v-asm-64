.section .data
.align 0x20
plaintxt:
	.asciz  "AA:ZZ/aa:zz The quick brown fox, etc.\n"
txtlen= . - plaintxt
rot:
	.byte   13			# The rotation value
upmin:
	.byte   'A'			# The uppercase ASCII lower-bound
upmax:
	.byte   'Z'			# The uppercase ASCII upper-bound
lomin:
	.byte   'a'			# The lowercase ASCII lower-bound
lomax:
	.byte   'z'			# The lowercase ASCII lower-bound

.section .bss
.align 0x20
.lcomm  Rvec, 0x10			# Mem in which to expand 'rot'
.lcomm  Avec, 0x10			# Mem in which to expand 'upmin'
.lcomm  Zvec, 0x10			# Mem in which to expand 'upmax'
.lcomm  avec, 0x10			# Mem in which to expand 'lomin'
.lcomm  zvec, 0x10			# Mem in which to expand 'lomax'

.section .text

.LrotateRange:
	movdqa  %xmm14, %xmm1		# copy of lower-bound byte-vector 
	pcmpgtb %xmm0, %xmm1		# create mask where <'A'; chars in src
	movdqa  %xmm0, %xmm2		# duplicate chars 
	pcmpgtb %xmm13, %xmm2		# create mask where >'Z'; chars in dest
	por     %xmm2, %xmm1		# derive mask for <'A' || >'Z'

	movdqa  %xmm15, %xmm2		# duplicate rot-vector 
	paddb   %xmm0, %xmm2		# add chars to rotation 
	movdqa  %xmm1, %xmm3		# duplicate mask 
	pandn   %xmm2, %xmm3		# retain upper-case chars -- xmm2 now spare

	movdqa  %xmm3, %xmm4		# duplicate result
	movdqa  %xmm3, %xmm5		# and again 
	pcmpgtb %xmm13, %xmm4		# create mask where >'Z' 
	pxor    %xmm6, %xmm6		# zero register
	pcmpgtb %xmm5, %xmm6		# create mask where < 0
	por     %xmm6, %xmm4		# derive mask where >'Z' || < 0
	movdqa  %xmm4, %xmm5		# duplicate mask 

	pand    %xmm13, %xmm4		# create subtraction vector
	psubb   %xmm4, %xmm3		# subtract 'Z' from out-of-bounds caps

	pand    %xmm14, %xmm4		# create addition vector
	paddb   %xmm4, %xmm3		# add 'A' to out-of-bounds caps

	pand    %xmm1, %xmm0		# Clear values we're going to 'set'
	paddb   %xmm3, %xmm0		# Upper case values are done

	retq

.globl _start
_start:
	pushq   %rbp
	mov     %rsp, %rbp		# Function prologue
	sub     $txtlen, %rsp		# Create space for the result
	and     $-0x10, %rsp		# Align RSP to a 16-byte boundary

	xor     %rdx, %rdx		# clear RDX
	mov     $0x05, %rbx		# move loop-count into RBX
	leaq    Rvec, %rdi		# copy start-address into RDI
.LexpandAgain:
	movb    rot(%rdx), %al		# copy source-byte into AL
	mov     $0x10, %rcx		# set RCX (stosb rep-count) to 16
rep     stosb				# repeat-store AL->&RDI
	inc     %rdx			# bump loop index
	dec     %rbx			# decrement loop counter
	jnz     .LexpandAgain		# repeat while RBX != 0

	xor     %rax, %rax		# Zero RAX, indexing register
	mov     $txtlen, %rdx		# Copy txtlen value into RDX

	movdqa  Rvec, %xmm15		# Copy rotation byte-vector into XMM15
.LcoreLoop:
	movdqa  plaintxt(%rax), %xmm0	# Copy chars to register
	movdqa  Avec, %xmm14		# Copy low val byte-vec into XMM14
	movdqa  Zvec, %xmm13		# Copy high val byte-vec into XMM13
	call    .LrotateRange		# Call routine (no ABI here, thanks)
	movdqa  avec, %xmm14		# Repeat for lower-case values
	movdqa  zvec, %xmm13
	call    .LrotateRange		# Call routine again
	movdqa  %xmm0, (%rsp, %rax)	# Store rotated result on the stack

	add     $0x10, %rax		# Add 16 to indexing register
	sub     $0x10, %rdx		# Sub 16 from textlen
	jg      .LcoreLoop		# Repeat cycle for remaining chars

	mov     $1, %rax		# 'write' syscall 
	mov     $1, %rdi		# stdout
	mov     %rsp, %rsi		# pointer to result[0]
	mov     $txtlen, %rdx		# number of chars to print
	syscall	

	movq    $0x3C, %rax		# 'sysexit' 
	xorq    %rdi, %rdi
	syscall	
