.section .data
gotmmx:
	.asciz	"Supports MMX"
gotsse:
	.asciz	"Supports SSE"
gotsse2:
	.asciz	"Supports SSE2"
gotsse3:
	.asciz	"Supports SSE3"
gotsse41:
	.asciz	"Supports SSE4.1"
gotsse42:
	.asciz	"Supports SSE4.2"
gotavx:
	.asciz	"Supports AVX"
gotaes:
	.asciz	"Supports AES"
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

	movl	ecxdata, %ecx
	test	$0x00080000, %ecx
	jz	done
	leaq	output, %rdi
	leaq	gotsse41, %rsi
	movw	$1, %ax
	call	printf

	movl	ecxdata, %ecx
	test	$0x00100000, %ecx
	jz	done
	leaq	output, %rdi
	leaq	gotsse42, %rsi
	movw	$1, %ax
	call	printf

	movl	ecxdata, %ecx
	test	$0x10000000, %ecx
	jz	done
	leaq	output, %rdi
	leaq	gotavx, %rsi
	movw	$1, %ax
	call	printf

	movl	ecxdata, %ecx
	test	$0x02000000, %ecx
	jz	done
	leaq	output, %rdi
	leaq	gotaes, %rsi
	movw	$1, %ax
	call	printf
done:
	movq	$0x3c, %rax
	movq	$0x01, %rdi
	syscall

