	.file	"libsyms.c"
	.text
	.p2align 4,,15
.globl otherRelocations
	.type	otherRelocations, @function
otherRelocations:
.LFB0:
	.cfi_startproc
	movq	cocopops@GOTPCREL(%rip), %rax
	addl	$1, (%rax)
	ret
	.cfi_endproc
.LFE0:
	.size	otherRelocations, .-otherRelocations
.globl cafebabe
	.data
	.align 4
	.type	cafebabe, @object
	.size	cafebabe, 4
cafebabe:
	.long	-341049654
.globl deadbeef
	.align 4
	.type	deadbeef, @object
	.size	deadbeef, 4
deadbeef:
	.long	-272716322
.globl countup
	.align 4
	.type	countup, @object
	.size	countup, 4
countup:
	.long	2018915346
.globl cocopops
	.align 4
	.type	cocopops, @object
	.size	cocopops, 4
cocopops:
	.long	-1785675584
	.ident	"GCC: (Ubuntu 4.4.3-4ubuntu5.1) 4.4.3"
	.section	.note.GNU-stack,"",@progbits
