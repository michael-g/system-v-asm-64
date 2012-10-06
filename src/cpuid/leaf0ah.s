.section .rodata
.LeaxFmtStr:
	.ascii "VersionID [7:0]:  %3hhi\n"
	.ascii "#GP regs/lcore:   %3hhi\n"
	.ascii "GP-PMC bit-width: %3hhi\n"
	.ascii "EBX bit-vec len:  %3hhi\n"
	.asciz ""
.LebxFmtStr:
	.ascii "Core cycle evt:   %3s\n"
	.ascii "Instr retd evt:   %3s\n"
	.ascii "Ref cycles evt:   %3s\n"
	.ascii "LLC ref evt:      %3s\n"
	.ascii "LLC misses evt:   %3s\n"
	.ascii "Branch:\n"
	.ascii " instr retd evt:  %3s\n"
	.ascii " misprd retd evt: %3s\n"
	.asciz ""

.Lyes:
	.asciz "yes"
.Lno:
	.asciz "no"
.LedxFmtStr:
	.ascii "#fixed fn PMC:    %3lli\n"
	.ascii "FF bit-width:     %3lli\n"
	.asciz ""

.section .text
	.globl _start
	.type _start, STT_FUNC
_start:
	mov    $0x0a, %eax	# Set EAX = 0AH
	cpuid
	mov    %eax, %r12d
	mov    %edx, %r13d

	mov    %eax, %esi
	and    $0xFF, %esi	# Clear all but VersionID 7:0
	mov    %eax, %edx
	shr    $0x08, %edx	# Shift GP count from 15:8 -> 7:0
	and    $0xFF, %edx	# Clear all but 7:0
	mov    %eax, %ecx
	shr    $0x10, %ecx	# Shift GP-bit-width from 23:16 -> 7:0
	and    $0xFF, %ecx	# Clear all but 7:0
	mov    %eax, %r8d
	shr    $0x18, %r8d	# Shift EBX bit-vec 31:24 -> 7:0
	and    $0xFF, %r8d	# Clear all but 7:0

	lea    .LeaxFmtStr, %rdi
	mov    $0x04, %al
	call   printf@PLT

	lea    .Lno, %rsi
	test   $0x01, %ebx	# Bit 00: Core cycle event not available if 1
	jne    .L0
	lea    .Lyes, %rsi
.L0:
	lea    .Lno, %rdx
	test   $0x02, %ebx	# Bit 01: Instruction retired event not available if 1
	jne    .L1
	lea    .Lyes, %rdx
.L1:
	lea    .Lno, %rcx
	test   $0x04, %ebx	# Bit 02: Reference cycles event not available if 1
	jne    .L2
	lea    .Lyes, %rcx
.L2:
	lea    .Lno, %r8
	test   $0x08, %ebx	# Bit 03: Last-level cache reference event not available if 1
	jne    .L3
	lea    .Lyes, %r8
.L3:
	lea    .Lno, %r9
	test   $0x10, %ebx	# Bit 04: Last-level cache misses event not available if 1
	jne    .L4
	lea    .Lyes, %r9
.L4:
	lea    .Lno, %r10
	test   $0x20, %ebx	# Bit 05: Branch instruction retired event not available if 1
	jne    .L5
	lea    .Lyes, %r10
.L5:	push   %r10

	lea    .Lno, %r10
	test   $0x40, %ebx	# Bit 06: Branch mispredict retired event not available if 1
	jne    .L6
	lea    .Lyes, %r10
.L6:	push   %r10

	lea    .LebxFmtStr, %rdi
	mov    $0x07, %al
	call   printf@PLT

	mov    %r13d, %esi	# EDX 4:0 Number of fixed-function performance counters (if Version ID > 1)
	and    $0x1F, %esi
	mov    %r13d, %edx	# EDX 12:5 Bit width of fixed-function performance counters (if Version ID > 1)
	shr    $0x05, %edx
	and    $0xFF, %edx
	
	lea    .LedxFmtStr, %rdi
	mov    $0x02, %al
	call   printf@PLT

	mov    $0x3c, %rax
	xor    %rdi, %rdi
	syscall

