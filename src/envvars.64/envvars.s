.section .data

	argc_str:     .asciz    "argc: %d\n"
	argv_str:     .asciz    "argv[%d]: %s\n"
	env_str:      .asciz    "env: %s\n"

.section .text
	.globl _start

_start:
	#
	# Application prologue. See page 29 in the System V 64-bit ABI 
	#
	movq       %rsp, %rbp         # Store the stack-pointer in RBP
	
#
# Print the number of command-line arguments
#
	# Function:
	#     printf
	# Parameters:
	#     RDI: address of the format-string $argc_str
	#     RSI: the number of arguments passed to this function
	#      AL: the parameter-count of this varargs function call
	# Returns:
	#     void
	movq       $argc_str, %rdi    # Store the address of the format-string in RDI
	movq       (%rbp), %rsi       # Store the cmd-line arg-count in RSI, by dereferencing RDP
	movq       $1, %rax           # Store the printf function's vararg-count in AL
	call       printf             # Invoke the standard library's printf function

#
# Print each command-line argument
#
	movq       (%rbp), %rcx       # Store the argument count in counter register RCX
	movq       %rcx, %r12         # Copy that value to the (protected) R12 register

.Lprintarg:
	movq       %rcx, %rbx         # Copy the count value to protected register RBX
	
	# Call function:
	#     printf
	# Parameters:
	#     RDI: address of the format-string "argv[%d]: %s\n"
	#     RSI: 1st value for conversion: index-count
	#     RDX: 2nd value for conversion: address of cmd-line arg
	#      AL: number of values to the varargs section of the call
	# Returns:
	#     void
	movq       $argv_str, %rdi    # Store the address of the format-string in RDI
	movq       %r12, %rsi         # Calculate the index value in RSI
	subq       %rcx, %rsi         # Subtract counter from arg-count to get the index
	                              # Calculate the pointer's address and store RDX
	leaq       0x8(%rbp, %rsi, 0x8), %rdx
	movq       (%rdx), %rdx       # Dereference that pointer to get the parameter's address
	movq       $0x2, %rax         # Set the varargs-count in the 'hidden' AL parameter
	
	call       printf             # Invoke printf

	movq       %rbx, %rcx         # Restore the counter from the protected RBX register

	loop       .Lprintarg         # Decrement RCX and loop again if not zero

#
# Print each environment variable
#
.Largsfinished:
	                              # Calculate the base address of the env-vars, which is:
	                              # %rbp + (8 * argc) + 16
	leaq       0x10(%rbp, %r12, 0x8), %r12 
	testq      %r12, %r12         # Test R12 against itself to find a zero-value
	jz         .Lexit

.Lprintenv:

	movq       $env_str, %rdi     # Store address of the format-string in RDI
	movq       (%r12), %rsi       # Store pointer to env-var in RSI
	movq       $0x1, %rax         # varargs component as 'hidden' parameter in AL

	call       printf

	addq       $0x8, %r12
	testq      $-0x1, (%r12) 
	jne        .Lprintenv

.Lexit:
	movq       $0x3C, %rax        # index of sys_write
	movq       $0x0, %rdi         # exit status
	syscall
