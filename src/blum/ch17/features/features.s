.section .data
gotmmx:
	.asciz	"Supports MMX"
gotsse:
	.asciz	"Supports SSE"
gotsse2:
	.asciz	"Supports SSE2"
gotsse3:
	.asciz	"Supports SSE3"
output:
	.asciz	"%s\n"
.section .bss
	.lcomm	ecxdata, 8
	.lcomm	edxdata, 8

.section .text
	.globl	_start

_start:

	nop
	movq	$1, %rax
	cpuid

	movl	%ecx, ecxdata
	movl	%edx, edxdata

	test	$0x00800000, %edx
	jz	done
	leaq	output, %rdi
	leaq	gotmmx, %rsi
	movw	$1, %ax
	call	printf

	movl	edxdata, %edx
	test	$0x02000000, %edx
	jz	done
	leaq	output, %rdi
	leaq	gotsse, %rsi
	movw	$1, %ax
	call	printf

	movl	edxdata, %edx
	test	$0x04000000, %edx
	jz	done
	leaq	output, %rdi
	leaq	gotsse2, %rsi
	movw	$1, %ax
	call	printf

	movl	ecxdata, %ecx
	test	$0x00000001, %ecx
	jz	done
	movq	$output, %rdi
	movq	$gotsse3, %rsi
	movw	$1, %ax
	call	printf

done:
	movq	$0x3c, %rax
	movq	$0x01, %rdi
	syscall

