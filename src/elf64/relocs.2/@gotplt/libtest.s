.section .data
	.globl	LtestVal
	.type	LtestVal, STT_OBJECT
LtestVal:
	.quad	0x1234

.section .text
	.globl	libfn
	.type	libfn, STT_FUNC
	.globl	targetfn
	.type	targetfn, STT_FUNC
targetfn:
	ret

libfn:
#	mov	$targetfn@GOTPLT, %rax		# Error: relocated field and relocation type differ in signedness
#	movabs	$targetfn@GOTPLT, %rax		# Error: relocated field and relocation type differ in signedness
#	mov	targetfn@GOTPLT, %rax		# Error: 8-byte relocation cannot be applied to 4-byte field
#	movabs	targetfn@GOTPLT, %rax		# Error: relocated field and relocation type differ in signedness
#	movd	$targetfn@GOTPLT, %rax		# Error: suffix or operands invalid for `movd'
#	leaq	$targetfn@GOTPLT, %rax		# Error: suffix or operands invalid for `lea'
#	movabsq	$targetfn@GOTPLT(%rip), %rax	# Error: junk `(%rip)' after expression
#	movabsq	targetfn@GOTPLT(%rip), %rax	# Error: suffix or operands invalid for `movabs'
#	movq	targetfn@GOTPLT(%rip), %rax	# Error: 8-byte relocation cannot be applied to 4-byte field
#	movabs	$targetfn@GOT, %rax		# Only gnerates a GOT64 relocation, contrary to http://www.amd64.org/viewvc/trunk/x86-64-ABI/low-level-sys-info.tex?r1=183&r2=185&sortby=log
	
	ret

