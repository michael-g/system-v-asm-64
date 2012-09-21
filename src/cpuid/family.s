.section .rodata
.LfamilyFmt:
	.ascii	"Stepping ID: 0x%02hhx\n"
	.ascii	"Model ID:    0x%02hhx\n"
	.ascii	"Family ID:   0x%02hhx\n"
	.asciz	""

.section .text
	.globl _start
	.type _start, STT_FUNC

_start:
	mov	%rsp, %rbp
	sub	$0x40, %rsp
	and	$~0x0F, %rsp

	mov	$1, %eax
	cpuid
	
	mov	%eax, %ebx		# Read Stepping ID
	and	$0x0F, %ebx
	movb	%bl, (%rsp)	
	
	mov	%eax, %ebx		# Read Model
	shr	$0x04, %ebx
	and	$0x0F, %ebx
	movb	%bl, 0x01(%rsp)
	
	mov	%eax, %ebx		# Read Family ID
	shr	$0x08, %ebx
	and	$0x0F, %ebx
	movb	%bl, 0x02(%rsp)

	mov	%eax, %ebx		# Read Extended Model ID
	shr	$0x10, %ebx
	and	$0x0F, %ebx
	movb	%bl, 0x03(%rsp)	

	mov	%eax, %ebx		# Read Extended Family ID
	shr	$0x14, %ebx
	and	$0xFF, %ebx
	movb	%bl, 0x04(%rsp)

	movb	0x02(%rsp), %al		# Loead the Family ID
	movb	%al, %al
	cmp	$0x06, %al		# Compare == 0x06
	je	.LcalcExtendFamilyId	# - branch if equal
	cmp	$0x0F, %al		# Compare == 0x0F
	jne	.LskipExtendFamilyId	# - branch if not equal

.LcalcExtendFamilyId:
	xor	%eax, %eax		# Clear reg
	movb	0x03(%rsp), %al		# Load Extended Model ID
	shl	$0x04, %eax		# Shift left by 4 bits (per CPUID docs)
	addb	0x01(%rsp), %al		# Add Model ID
	movb	%al, 0x01(%rsp)		# Store over Model ID

.LskipExtendFamilyId:
	movb	(%rsp), %al		# Set Stepping ID as param[1]
	mov	%al, %al
	mov	%eax, %esi

	movb	0x01(%rsp), %al		# Set Model ID as param[2]
	mov	%al, %al
	mov	%eax, %edx

	movb	0x02(%rsp), %al		# Set Family ID as param[3]
	mov	%al, %al
	mov	%eax, %ecx

	lea	.LfamilyFmt, %rdi	# Set format-string asparam[0]
	mov	$0x03, %al		# Set #args in AL

	call	printf@PLT

	mov	$0x3c, %rax
	xor	%rdi, %rdi
	syscall

