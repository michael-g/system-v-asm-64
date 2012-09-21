.section .text

	.globl _start
_start:
	mov       %rsp, %rbp
	sub       $0x40, %rsp

	mov       $0x8, %rdi
	mov       $0x80000004, %esi
.LreadBrandString:
	mov       %esi, %eax
	cpuid
	mov       %eax, 0x00(%rsp,%rdi,4)
	mov       %ebx, 0x04(%rsp,%rdi,4)
	mov       %ecx, 0x08(%rsp,%rdi,4)
	mov       %edx, 0x0c(%rsp,%rdi,4)
	sub       $0x1, %rsi
	sub       $0x4, %rdi
	jge       .LreadBrandString

	movb      $0x00, 0x30(%rsp)

	mov       %rsp, %rdi
	call      puts@PLT

	mov       $0x3c, %rax
	mov       $0x01, %rdi
	syscall

