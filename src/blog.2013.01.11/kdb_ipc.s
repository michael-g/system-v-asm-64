.section .rodata
.LnotAlignedStr:
	.asciz  "alignment"                   # Error to report if data is misaligned

.section .text

.globl compress
.type compress, STT_FUNC


# Compress function
# Parameters
# 0: RDI: address of bytes to be compressed
# 1: ESI: count of bytes to be compressed
# Returns
#    RAX: pointer to malloc'd bytes containing IPC bytes as struct { uint32 len; uchar* bytes }
compress:
	test     $0x0F, %rdi                  # Calc alignment (sets eflags)
	jz       .LalignmentOk                # If 16-byte aligned jump
	lea      .LnotAlignedStr(%rip), %rdi  # Set parameter to krr
	jmp      krr@plt                      # Call extern error reporting function
	
.LalignmentOk:
	push     %rbp                         # Function prologue
	push     %rbx                         # Store callee-saved registers
	push     %r12                         #   "
	push     %r13                         #   "
	push     %r14                         #   "
	push     %r15                         #   "
	mov      %rsp, %rbp                   # Store RSP in RBP for simple stack recovery
	and      $~0x0F, %rsp                 # Align stack to 16-byte boundary
	sub      $0x20, %rsp                  # Keep alignment and reserve 4 QW stack space
	mov      %rdi, 0x18(%rsp)             # Store src.addr on stack
	mov      %rsi, 0x10(%rsp)             # Store src.length on stack
	xor      %rdi, %rdi                   # Clear reg64
	mov      $0xcafebabe, %edi            # Create magic number for GDB visibility
	mov      %rdi, 0x00(%rsp)             # Store in 0x00(%rsp)
.LmallocDest:
	mov      %rsi, %rdi                   # Copy input-len to param[0] for call to malloc
# RDI: src.length (param[0] to malloc)
#!CALL
	call     malloc@PLT                   # Call malloc (pic)
#¬RDI: ???
# RAX: dst.addr_start
	cmp      $0x00, %rax                  # Compare result with zero
	je       .LcompressEpilogue           # - if NULL, jump to exit handler
.LmallocOk:
	mov      %rax, 0x08(%rsp)             # Store dst.addr on stack
# 0x18(%rsp) src.addr_start
# 0x10(%rsp) src.length
# 0x08(%rsp) dst.addr_start
# 0x00(%rsp) [magic_num]
	mov      %rax, %r15                   # Copy dst.addr 
# R15: dst.pos
	mov      %rax, %r11                   # Copy dst.addr again for block-idx
# R11: dst.block.addr
	mov      $0x01, %r9                   # Set bitmask = 0x01 
# R9:  dst.block.bit_mask
	movb     $0x00, (%r11)                # Write zero to the block_idx byte
	add      $0x01, %r15                  # Increment dst.pos
	xor      %rax, %rax                   # Zero register for MOV to stack
#(RAX: 'zero'
	mov      $0xFF, %rcx                  # Set dict.max_idx (255) as counter, then count to zero
#(RCX: dict.length
	sub      $0x800, %rsp                 # Subtract dict.length * sizeof(void*) from SP
	
.Lcompress0:
# Loop to zero the stack dictionary values
	movq     %rax, (%rsp, %rcx, 8)        # Write zeroed reg to memory
	sub      $0x01, %rcx                  # Decrement counter
	jge      .Lcompress0                  # Loop again if counter >= 1
# 0x818(%rsp) src.addr_start
# 0x810(%rsp) src.length
# 0x808(%rsp) dst.addr_start
# 0x800(%rsp) [magic_num]
# 0x000(%rsp) dictionary
# Stack is 16-byte aligned
	mov      0x818(%rsp), %r14            # Retrieve src.addr_start
	mov      0x810(%rsp), %r8             # Retrieve src.length 
	mov      %r14, %r13
	add      %r8, %r13                    # Caclulate src.addr_end
	mov      0x808(%rsp), %r12            # Retrieve dst.addr_start for use as a cursor
# R14: src.cursor
# R13: src.addr_end
# R12: dst.cursor
# R11: dst.block_idx.count (reserved: assigned below)
# R10: dst.block_idx.addr (reserved: assigned below)
# R9 : dst.block_idx.value (reserved: assigned below)
# RDX: reserved for pcmpstri.mem[arg1].len; counts src bytes remaining
# RAX: reserved for pcmpstri.xmm[arg0].len
# RCX: reserved for pcmpstri.result
	movdqa   (%r14), %xmm14               # Load aligned
	movdqa   0x10(%r14), %xmm15           # Load subsequent bytes
	movdqa   %xmm15, %xmm0                # Copy subsequent bytes for destruction in PALIGNR
	palignr  $1, %xmm14, %xmm0            # Rotate one byte from DEST into SRC and overwrite DEST
	pxor     %xmm14, %xmm0                # Create dict.indicies
# X15: subsequent src bytes
# X14: src bytes
# X 0: dict indices
	
	movb     $0x00, (%r12)                # Write the index byte to dst
	add      $0x09, %r12	              # Add 9 bytes (index+8) to dst.cursor
	movq     (%r14), %rax                 # Load 8 src bytes to R64
	movq     %rax, -0x08(%r12)            # Write 8 bytes uncompressed to dst.cursor-8
	mov      %r14, %r8                    # Copy src.cursor
	add      $0x08, %r8                   # Create src.sentinel
.LwriteFirstEightDictBytes:
#(RBX: dict.index
#(R8 : src.sentinel
	pextrb   $0, %xmm0, %rbx              # Extract index byte
	psrldq   $1, %xmm0                    # Rotate dict.indices by one byte
	mov      %r14, (%rsp,%rbx,8)          # Write src.cursor to dict[idx]
	add      $0x01, %r14                  # Increment src.cursor
	cmp      %r14, %r8                    # Check whether src.cursor == src.sentinel
	jne      .LwriteFirstEightDictBytes
	movb     $0x00, (%r12)                # Write index byte
	add      $0x09, %r12                  # Add 9 bytes (idx+8) to dst.cursor
	movq     (%r14), %rax                 # Load 8 src bytes to R64
	movq     %rax, -0x08(%r12)            # Write 8 bytes uncompressed to dst.cursor-8
	add      $0x08, %r8                   # Add 8 to src.sentinel
.LwriteNextEightDictBytes:
	pextrb   $0, %xmm0, %rbx              # Extract index byte
	psrldq   $1, %xmm0                    # Rotate dict.indices by one byte
	mov      %r14, (%rsp,%rbx,8)          # Write src.cursor to dict[idx]
	add      $0x01, %r14                  # Increment src.cursor
	cmp      %r14, %r8                    # Check whether src.cursor == src.sentinel
	jne      .LwriteNextEightDictBytes

.LstartRealCompressionRoutine:
	mov      %r13, %rdx                   # Copy src.addr_end 
	sub      %r14, %rdx                   # Subtract src.cursor to derive remaining src byte count
	xor      %r11, %r11                   # Zero block_idx.counter
	mov      %r12, %r10                   # Set block_idx.addr
	xor      %r9,  %r9                    # Zero block_idx.value
	xor      %r8,  %r8                    # Create counter for bytes rotated in XMM register
	mov      $0x10, %rdx                  # Set arg to PCMPESTRI 

# X15: subsequent src bytes
# X14: src bytes
# R14: src.cursor
# R13: src.addr_end
# R12: dst.cursor
# R11: dst.block_idx.count
# R10: dst.block_idx.addr
# R9 : dst.block_idx.value
# R8 : XMM rotation count
# RDX: counts src bytes remaining; used for PCMPESTRI.args[0].len
# RCX: used for pcmpstri.result; also temp register in meantime
# RAX: used for PCMPESTRI.args[1].len; should be (src.addr_end - dict[dict.idx])
#----temps----
#(X 0: dict indices
#(RBX: dict index byte (in %bl)
.LcompressAAcreateDictIdcs:
	movdqa    %xmm15, %xmm14               # Copy now-current src bytes
	movdqa    0x10(%r14), %xmm15           # Load subsequent DQW src bytes
	movdqa    %xmm15, %xmm0                # Copy subsequent DQW for destruction in PALIGNR
	palignr   $1, %xmm14, %xmm0            # Rotate one byte from DEST into SRC and overwrite DEST
	pxor      %xmm14, %xmm0                # Create dict.indicies
.LcompressAB:
	pextrb    $0, %xmm0, %rbx              # Copy dict.idx byte
	movq      (%rsp,%rbx,8), %rcx          # Load pointer at dict[dict.idx]
	mov       %r14, (%rsp,%rbx,8)          # Write src.cursor to dict[dict.idx]
	cmp       $0x00, %rcx                  # Test whether the value is null
	jz        .LcompressADwriteDict        # If value is zero, skip to where src.cursor is written to dict[dict.idx]
.LcompressAC:
	movdqu    (%rcx), %xmm3                # Load prev src bytes for comparison
	mov       %r13, %rax                   # Copy src.addr_end
	sub       %rcx, %rax                   # Calculate distance from dict[dict.idx] to src.addr_end
	pcmpestri $0x18, %xmm3, %xmm14         # Compare two registers; imm8, arg1(rdx), arg2(rax) => rcx
	cmp       $0x02, %rcx                  # Compare result with min compression length
	jl        .LcompressADwriteDict        # No match or no significant match; jump to code which writes dictionary
	
	# TODO
	# Check whether match.length < 0x10 (or src.remaining or dict[dict.idx].remaining)
	# - if not >= then full match has been found and can be written
	# - if >= then potentially further match has been found
	#   Note max match length 255
.LcompressADwriteDict:
	add       $0x01, %r14                  # Increment cursor
	sub       $0x01, %rdx                  # Decrement remaining src count
.LcompressAErotateRegs:
	ret

##(RBX: dict.index
##(R8 : holds src byte
#
#	# Write index byte to dst.cursor
#	# Increment dst.cursor
#	#  
#
#	movdqu   (%r14), %xmm0                # Else load-unaligned
#	movdqa   (%r14, %rcx), %xmm15         # Load-aligned src-data offset by RCX
#	movdqa   0x10(%r14, %rcx), %xmm14     # Load-aligned the following 16 src-data bytes
#	movdqa   %xmm0, %xmm2                 # Copy reg contents for rotation
#	psrldq   $1, %xmm2                    # Rotate contents by 1 byte for XOR
#	pxor     %xmm0, %xmm2                 # Create dictionary void* indices
## XM0:  src.data (offset 0)
## XM15: src.data (offset by misalignment) 
## XM14: src.data (offset by misalignment + 16)
## XM2:  dict indices
#	lea      0x10(%r14), %rdi             # Calc vale of src.pos + 16
#	and      $~0x0f, %rdi                 # Use AND 0xffffff0 to reduce value to address of next 16-byte alignment
## RDI:  next src address of 16-byte alignment
#
#.LfindAlignment:
#	pextrb   $0, %xmm2, %rax              # Extract 0'th dict-idx byte to RAX (clearing hi-bytes)
## RAX:  current dict index
#	psrldq   $1, %xmm2                    # Shift XMM dict-indices by 1
#	mov      %r14, (%rsp, %rax, 8)        # Copy src.addr+counter to the void* offset in dict
#	test     $0x07, %rsi                  # Bitwise-AND counter with 7; yields counter mod(8)
#	jne      .LfindAlignmentSkipBlockIdx  # Test whether time for a block-index byte
#	movb     $0, (%r15)                   # Write block-index byte
#	add      $1, %r15                     # Increment dst.pos
#.LfindAlignmentSkipBlockIdx:
#	pextrb   $0, %xmm0, %rax              # Copy 0'th src byte to RAX (clearing hi-bytes)
## RAX:  current src byte
#	add      $0x01, %r14                  # Increment src.pos
#	psrldq   $1, %xmm0                    # Shift XMM0 (src) bytes 1
#	movb     %al, (%r15)                  # Write src byte to dest 
#	cmp      %rdi, %rdx                   # Test whether 16-byte aligned yet
#	jne      .LfindAlignment
#
## R15: dst.pos 
## R14: src.pos
## R13: src.len 
## R12: src.addr_end
## R11: dst.block.addr
## R10: dst.block.rpt_count
## R9:  dst.block.bit_mask
## unused RAX, RBX, RCX, RDX, RDI, RSI, R8
#
#.LstartAlignedProcessing:
#.LcreateDictIdxBytes:
#	movdqa   %xmm15, %xmm0                # Copy src bytes align+0 to align+15 to XMM0
#	movdqa   %xmm14, %xmm1                # Copy subsequent bytes to XMM1
#	movdqa   %xmm14, %xmm2                # Copy those same bytes (for destruction) to XMM2
#	palignr  $1, %xmm0, %xmm2             # Rotate one byte from XMM2 into XMM0 and overwrite XMM2
#	pxor     %xmm0, %xmm2                 # Create dict indices
## XM0: src[pos].data
## XM1: src[pos+16].data
## XM2: dict.bytes
#	
#.Lcompress1:
## Extract dictionary index and test whether dict[addr].value is not zero (i.e. that it contains
## an address)
#	pextrb   $0, %xmm2, %rdx              # Extract 0'th dict-byte to r64 (zeroes upper bytes)
## RDX: dict.index
#	lea      (%rsp, %rdx, 8), %rdi        # Calc dict[x].address
## RDI: dict.address
#	cmp      $0x00, (%rdi)                # Test whether index has previously been written
#	jne      .LdictLookupPossible         # - if written (ie not zero), perform jump
## unused RAX, RBX, RCX, RSI, R8
#.LdictLookupMiss:
#	# handler for dict-lookup miss
## RDX: dict.index
## RDI: dict.address
#	psrldq   $1, %xmm2                    # Rotate XMM reg for next loop iteration
#	mov      %rdx, (%rdi)                 # Write src[x].addr to dict at offset idx+sizeof(void*)
#	pextrb   $0, %xmm0, %rbx              # Copy source-byte from XMM0 to r64
## RBX: src.byte.value
#	movb     %bl, (%r15)                  # Copy source-byte from r8 to dst.pos
#
#	# Adjust src bytes by 'streaming rotation' with palignr
#	movdqa   %xmm1, %xmm3                 # Copy subsequent src-byte vector
#	palignr  $1, %xmm0, %xmm3             # Copy-in one byte from XMM3 to XMM0 and overwrite XMM3
#	movdqa   %xmm3, %xmm0                 # Set result on XMM0
#	psrldq   $1, %xmm1                    # Rotate the copied src-byte out of XMM1
#
#	# loop-counter maths and condition-check
#	add      $0x01, %r14                  # Increment src.pos
#	cmp      %r14, %r12                   # Test for loop exit-condition TODO this only checks src.pos == src.end_addr
#	jne      .Lcompress1                  # - if not equal, loop again
#
#	# Loop complete, skip if-clause implementations
#	jmp      .Lcompress3                  # - else, skip handle for existing-dict-value
#	
#.LdictLookupPossible:
#	# Handler for dict-value-already-written
## R15: dst.pos 
## R14: src.pos
## R13: src.len 
## R12: src.addr_end
## R11: dst.block.addr
## R10: dst.block.rpt_count
## R9:  dst.block.bit_mask
## RDX: dict.index
## RDI: dict.address
#	mov       %r12, %rax                   # Copy src.addr_end to RAX
#	sub       %r14, %rax                   # Calculate src.remaining by subtracting src.pos; string.length now in EAX
#	mov       $0x10, %edx                  # Set 16 on EDX 
#	pcmpestri $0x18, (%rdi), %xmm0         # Derive match-len between byte arrays
#	jnc       .LnoMatch                    # Jump if match-count = 0; CFlag set if ECX > 0, else cleared
#	jo        .LfullMatch                  # Jump if match-count = 16; OFlag set if ECX = 16
#	cmp       $0x01, %al                   # Test whether match-count = 1; 
#	je        .LnoMatch                    # - if equal, jump to non-matching handler
#
#.LsubXmmMatch:
#
#.LnoMatch:
#
#.LfullMatch:
#
#.Lcompress3:
#
#.LcompressLdXmmA:
#
#.LcompressLdXmmAEnd:


.LcompressEpilogue:
	mov      %rbp, %rsp                   # Restore SP for epilogue
	pop      %r15                         #
	pop      %r14                         #
	pop      %r13                         #
	pop      %r12                         #
	pop      %rbx                         #
	pop      %rbp                         #
	ret
	

# Extract a byte integer value from xmm2 at the source byte offset specified by imm8 
# into rreg or m8. The upper bits of r32 or r64 are zeroed.
#
#	pextrb   imm8, %xmmN, reg/m8

# Concatenate destination and source operands. After completion, dest contains imm8 low-order bytes 
# in its high-byte section. 
#
# eg: 
# xmm0: 0x100f0e0d_0c0b0a09_08070605_04030201
# xmm1: 0xffffffff_ffffffff_ffffffff_ffffffff
# palignr $3, xmm0, xmm1
# xmm1: 0x030201ff_ffffffff_ffffffff_ffffffff

#	lea      .Lcompress3(,%rcx,8), %r13   # Calculate jump target address; psrldq+jmp=8bytes
#	jmp      *%r13                        # Perform jump
#
#.Lcompress3:
#	jmp      .Lcompress2                  # Jump to block exit
#	nopw     (%rax,%rax,1)                # NOP: 6 bytes = sizeof(psrldq); unreachable; cf .byte 0x66, 0x0F, 0x1F, 0x44, 0x00, 0x00
#	psrldq   $1, %xmm15                   # Rotate XMM register right by 1 byte
#	jmp      .Lcompress2                  # Jump to block exit
#	psrldq   $2, %xmm15                   # Rotate XMM register right by 2 bytes
#	jmp      .Lcompress2                  # Jump to block exit
#	psrldq   $3, %xmm15                   # ...
#	jmp      .Lcompress2
#	psrldq   $4, %xmm15
#	jmp      .Lcompress2
#	psrldq   $5, %xmm15
#	jmp      .Lcompress2
#	psrldq   $6, %xmm15
#	jmp      .Lcompress2
#	psrldq   $7, %xmm15
#	jmp      .Lcompress2
#	psrldq   $8, %xmm15
#	jmp      .Lcompress2
#	psrldq   $9, %xmm15
#	jmp      .Lcompress2
#	psrldq   $10, %xmm15
#	jmp      .Lcompress2
#	psrldq   $11, %xmm15
#	jmp      .Lcompress2
#	psrldq   $12, %xmm15
#	jmp      .Lcompress2
#	psrldq   $13, %xmm15
#	jmp      .Lcompress2
#	psrldq   $14, %xmm15
#	jmp      .Lcompress2
#	psrldq   $15, %xmm15
#	jmp      .Lcompress2
#.Lcompress2:
