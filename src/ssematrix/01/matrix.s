.section .data
	.align 0x10
matrix0:				# Given matris [ 1, 2 ] 
	.int	1, 2, 3, 4		#              [ 3, 4 ]
matrix1:				# and matrix   [ 5, 6 ]
	.int	5, 6, 7, 8		#              [ 7, 8 ]
outfmt:					# We need output [ 1*5+1*6, 2*7+2+8 ]
	.ascii	"Result is:\n"		#                [ 3*5+3*6, 4*7+4*8 ] 
	.ascii	"\t[ %d, %d ]\n"	# and hence    [ 11, 30 ]
	.asciz	"\t[ %d, %d ]\n"	#              [ 33, 60 ]
calcfmt:
	.ascii	"Calc is:\n"
	.ascii	"\t[ %d, %d ]   [ %d, %d ]\n"
	.asciz	"\t[ %d, %d ] x [ %d, %d ]\n"

.section .bss
	.lcomm	result, 8*8

.section .text
	.globl	_start
_start:
	nop

	movdqa   matrix0, %xmm0		# xmm0 = [ 1, 2, 3, 4 ] 
	movdqa   matrix1, %xmm1		# xmm1 = [ 5, 6, 7, 8 ]
	movsldup %xmm0, %xmm8		# xmm8 = [ 1, 1, 3, 3 ]
	movddup  %xmm1, %xmm7		# xmm7 = [ 5, 6, 5, 6 ]
	pmuldq   %xmm7, %xmm8		# xmm5 = [ 1*5, 3*5 ] 
	pshufd   $0x11, %xmm1, %xmm6	# xmm6 = [ 6, 5, 6, 5 ] (1+0+16+0)=17=0x11 
	movsldup %xmm0, %xmm7		# xmm7 = [ 1, 1, 3, 3 ]
	pmuldq   %xmm6, %xmm7		# xmm7 = [ 1*6, 3*6 ]
	paddq    %xmm7, %xmm8		# xmm8 = [ 11, 33 ]
	movq     %xmm8, result		# Store 11 to result[0]
	psrldq   $0x08, %xmm8		# xmm8 = [ 33, .. ]	
	movq     %xmm8, result+0x10	# Store 33 to result[2]
	
	movshdup %xmm0, %xmm8		# xmm8 = [ 2, 2, 4, 4 ]
	pshufd   $0x22, %xmm1, %xmm7	# xmm7 = [ 7, 5, 7, 5 ] (2+0+32+0)=34=0x22
	pmuldq   %xmm7, %xmm8		# xmm8 = [ 2*7 , 4*7 ]
	pshufd   $0x33, %xmm1, %xmm6	# xmm6 = [ 8, 5, 8, 5 ] (3+0+48+0)=51=0x33
	movshdup %xmm0, %xmm7		# xmm7 = [ 2, 2, 4, 4 ]
	pmuldq   %xmm6, %xmm7		# xmm7 = [ 2*8, 4*8 ]
	paddq    %xmm7, %xmm8		# xmm8 = [ 30, 60 ]
	movq     %xmm8, result+0x08	# Store 30 to result[1]
	psrldq   $0x08, %xmm8		# xmm8 = [ 60, .. ]
	movq     %xmm8, result+0x18	# Store 60 to result[2]

	subq     $0x08, %rsp		# Set RSP so that stack ends-up aligned for printf
	movb     $0x08, %al
	leaq     calcfmt, %rdi		# arg[0]
	movsxd   matrix0+0x00, %rsi	# 
	movsxd   matrix0+0x04, %rdx	# 
	movsxd   matrix1+0x00, %rcx	#
	movsxd	 matrix1+0x04, %r8	#
	movsxd   matrix0+0x08, %r9	# arg[5]
	movsxd   matrix1+0x0C, %r11	#
	pushq    %r11			# arg[8] - stack args in reverse order
	movsxd   matrix1+0x08, %r11	#
	pushq    %r11			# arg[6]
	movsxd   matrix0+0x0C, %r11	#
	pushq    %r11			# arg[5]
	call     printf
	addq     $0x20, %rsp		# Reset RSP, remove args and spacer

	movb     $0x04, %al
	leaq     outfmt, %rdi
	movq     result, %rsi
	movq     result+0x08, %rdx
	movq     result+0x10, %rcx
	movq     result+0x18, %r8
	call     printf

	movq	$0x00, %rdi
	call	exit
