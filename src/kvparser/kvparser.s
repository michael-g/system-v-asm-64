.section .rodata

.align 0x20
toLowVec:
	.byte	0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20
	.byte	0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20
	        #          1         2         3         4
testStr:        #01234567890123456789012345678901234567890123
	.asciz	"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;"

.align 0x20
oStr:
	.asciz	"Result %d\n"

.section .text

.globl _start
.type _start, STT_FUNC

.globl findKeyLen
.type findKeyLen, STT_FUNC

_start:
	
	and        $-0x10, %rsp

	leaq       testStr, %rdi
	mov        $0x2c, %esi
	call       findKeyLen

	mov        %eax, %esi
	leaq       oStr, %rdi
	mov        $0x01, %al
	call       printf

	movq       $0x3c, %rax
	movq       $0x00, %rdi
	syscall

findKeyLen:
	xor        %r8d, %r8d                # zero DW of R8
.L10:
	mov        $0x3a3b3d, %eax           # 0x3a3b3d are ASCII for :; and = respectively
	movd       %eax, %xmm0               # copy char-set to XMM0

	mov        $0x03, %ax                # copy byte len to AX
	movzx      %ax, %rax                 # set length of arg[0] (comparison set)
	xor        %rdx, %rdx                # clear RDX
	mov        %esi, %edx                # set length of arg[1] (string under test)
	pcmpestri  $0x00, (%rdi), %xmm0      # find instances of chars in XMM0 in (%RDI) up to set limits
	
	cmp        $0x10, %cl
	jl         .L20

	add        $0x10, %rdi
	add        $0x10, %r8d
	sub        $0x10, %esi
	jle        .L30
	jmp        .L10
.L20:
	mov        %ecx, %eax
	add        %r8d, %eax
	ret
.L30:
	mov        $-0x01, %eax
	ret
