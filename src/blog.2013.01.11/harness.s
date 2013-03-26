
.comm   ipcsrc, 2406, 32                      # let common symbol be 0x966 bytes long, aligned to 32-byte boundary
.Lsym:
	.asciz  "VOD.L"                       # The test symbol (must be < 8 bytes incl null terminator)
.Lsym_len: 
	.int    . - .Lsym                     # The length of the above C-string

.globl _start
.type _start, STT_FUNC

.globl krr
.type krr, STT_FUNC

krr:
	ret

_start:
# Create IPC bytes to compress 
	movl     $0x0190000b, ipcsrc(%rip)    # The IPC vector header: sym-vec, len 400
	lea      6+ipcsrc(%rip), %rax         # Load address of ipcsrc
	mov      .Lsym(%rip), %rbx            # Load symbol's ASCII value into QW register
	mov      $0x190, %rcx                 # Set loop-count
	xor      %r8, %r8                     # Zero QW register (will load DW value into it)
	xor      %rdx, %rdx                   # Zero counter register
	movl     .Lsym_len(%rip), %r8d        # Load symbol length to DW register

.Lgen_ipc_start:
# Loop to write the sym-vector
	mov      %rbx, (%rax, %rdx)           # Write symbol to ipcsrc BSS location
	add      %r8, %rdx                    # Increment stride by sym-length
	sub      $1, %rcx                     # Decrement counter 
	jne      .Lgen_ipc_start              # Loop again if count >= 1

	lea      ipcsrc(%rip), %rdi           # Copy address of ipcsrc to RDI (call param[0])
	lea      (%rax, %rdx), %rsi           # Copy the end-address of the IPC bytes (call param[1])
	sub      %rdi, %rsi                   # Calculate ipcbytes.length

	call     compress@PLT                 # Call shared library

	mov      $0x3c, %rax                  # Invoke exit
	mov      $0x00, %rdi
	syscall

