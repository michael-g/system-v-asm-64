.section .data

argc_str: 	.asciz	"argc: %d\n"
argv_str: 	.asciz	"argv[%d]: %s\n"
null_ptr_str:	.asciz	"null separator: %d\n"
env_str: 	.asciz	"%2d: %s\n"

.section .text
.globl	_start
_start:
	movl	%esp, %ebp
	
	pushl	(%ebp)
	pushl	$argc_str
	call	printf
	
	addl	$8, %esp	# clear params

	# use EAX to store the starting address for the cmd line args

	movl	%ebp, %eax	# currently EBP points to argc
	addl	$4, %eax	# move past argc

	movl	(%ebp), %ecx	# move the argument-count into ECX

print_arg:
	pushl	%eax		# store EAX
	pushl	%ecx		# store ECX
	
	neg	%ecx		# make ECX = -ECX
	addl	(%ebp), %ecx	# do argc + (-ECX)

	pushl	(%eax)		# push address referenced by EAX 
	pushl	%ecx		# push argument count <- TODO
	pushl	$argv_str	# push format-string
	call	printf
	addl	$12, %esp	# discard the three parameters to printf

	popl	%ecx		# store ECX value from before the call
	popl	%eax		# store EAX value from before the call 

	addl	$4, %eax	# point EAX at the next parameter

	loop	print_arg

skip_null_var:
	pushl	%eax

	pushl	(%eax)		# push the value at the address stored in EAX
	pushl	$null_ptr_str	# push the address of the format-string
	call	printf		# print
	addl	$8, %esp	# Forget the top two stack parameters...

	popl	%eax		# ... and restore the value of EAX

	addl	$4, %eax	# Bump pointer value in EAX
	xorl	%ebx, %ebx	# Reset EBX to 0

print_env:

	cmpl	$0, (%eax)	# Compare value at address referenced by EAX to zero
	je	exit		# if zero (the null pointer), then exit
	
	pushl	%eax		# save EAX
	pushl	%ebx		# save EBX

	pushl	(%eax)
	pushl	%ebx
	pushl	$env_str
	call	printf
	addl	$12, %esp	# Forget top three parameters

	popl	%ebx		# Restore EBX
	popl	%eax		# Restore EAX

	addl	$4, %eax	# Bump EAX to next environment variable pointer
	inc	%ebx		# Increment index-counter

	jmp	print_env;	# Repeat if not zero (ie: null pointer)

exit:
	movl	$1, %eax
	movl	$0, %ebx
	int	$0x80
