# (c) Michael Guyver, 2012, all rights reserved. Permission to use, copy, modify and distribute the 
# software is hereby granted for educational use which is non-commercial in nature, provided that 
# this copyright  notice and following two paragraphs are included in all copies, modifications and 
# distributions.
#
# THIS SOFTWARE AND DOCUMENTATION IS PROVIDED "AS IS," AND NO REPRESENTATIONS OR WARRANTIES ARE 
# MADE, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO, WARRANTIES OF MERCHANTABILITY OR 
# FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE SOFTWARE OR DOCUMENTATION WILL NOT 
# INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
#
# COPYRIGHT HOLDERS WILL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL OR CONSEQUENTIAL DAMAGES 
# ARISING OUT OF ANY USE OF THE SOFTWARE OR DOCUMENTATION.

.include "savereg.macro.s"

.section .rodata
    .align    0x10
.LbadTypeStr:
    .asciz   "vectype"

.section .text

.globl    mgBitwiseOr
.type     mgBitwiseOr, STT_FUNC

.LhandleBadType:                            # Handler for invalid input vector-type
    lea        .LbadTypeStr(%rip), %rdi     # Load address of error message
    callq      krr@PLT                      # Call kdb's error-reporting function
    jmp        .LrestoreStackForExit        # Exit via the clean-up function

.LsuccessExit:
    mov        %r14, %rax                   # Copy result address to RAX

.LrestoreStackForExit:
    mov        %rbp, %rsp                   # Restore SP
    pop        %r15                         # Restore non-durable registers
    pop        %r14
    pop        %r13
    pop        %r12
    pop        %rbx
    pop        %rbp
    vzeroupper                              # Guard against expensive AVX->SSE transition 
    ret                                     # Exit to caller

    .align 0x10                             # Align entry-point to 16-byte boundary

mgBitwiseOr:
    push       %rbp                         # Push all non-durable registers
    push       %rbx
    push       %r12
    push       %r13
    push       %r14
    push       %r15
    mov        %rsp, %rbp                   # Store updated SP
    sub        $0x10, %rsp                  # Ensure alignment reserves at least 16 bytes
    and        $-0x20, %rsp                 # Align SP to 32-byte boundary

.LstoreInputArgs:
    mov        %rdx, 0x08(%rsp)             # Store arg2
    mov        %rcx, 0x00(%rsp)             # Store arg3
    mov        %rdi, %r12                   # Copy/store arg0
    mov        %rsi, %r13                   # Copy/store arg1

    vzeroupper                              # Guard against expensive SSE->AVX transition
    m_save_regs_avx
    call       *0xa8(%rsp)
    m_restore_regs_avx

.LtestInputType:
    cmpb       $4, 2(%rdi)                  # Compare input vec-tye with 4
    jne        .LhandleBadType              #   branch if not-equal

.LcreateResultObject:
    mov        $1, %rdi                     # arg0: vector-type
    movq       8(%r12), %rsi                # arg1: copy input vector-length
    callq      ktn@PLT                      # Create result vector
    mov        %rax, %r14                   # Safe-store result pointer

.LsetupAvxConstants:
    xor        %rax, %rax                   # Zero register
    movb       8(%r13), %al                 # Copy mask byte-value
    movq       %rax, %xmm0                  # Copy again to XMM0

    vpxor      %xmm1, %xmm1, %xmm1          # Clear XMM0: arg[2] = arg[0] ^ arg[1]
    vpshufb    %xmm1, %xmm0, %xmm0          # Byte-wise shuffle: msk=arg[0], val=arg[1], dst=arg[2]; 2B/4-282, p. 284
    vpcmpeqw   %xmm2, %xmm2, %xmm2          # Set all bits in XMM2
    
    vpcmpeqw   %xmm3, %xmm3, %xmm3          # Set all bits in XMM3: 0xffff_ffff_ffff_ffff_...
    vpsrlw     $15, %xmm3, %xmm3            # Rotates by 15 bits:   0x0001_0001_0001_0001_...
    vpackuswb  %xmm3, %xmm3, %xmm3          # Packs:                0x0101_0101_0101_0101_...

.LsetupLoopCounter:
    xor        %rdx, %rdx                   # Clear loop-counter
    mov        8(%r14), %r15                # Copy result->length to R15

.LloopStart:
    mov        %r15, %rax                   # Copy vec-len
    sub        %rdx, %rax                   # Calculate remaining
    je         .LsuccessExit                #   branch to exit-handler if remaining == 0
    cmp        $0x10, %rax                  # Compare remaining with 16
    jl         .LsubXmmRemaining            #   branch if < 16
    je         .LprocessOneXmm              #   branch if == 16
    lea        0x10(%r12,%rdx), %rbx        # Calculate address of read cursor
    test       $0x3f, %rbx                  # Test for 64-byte alignment
    jnz        .LprocessOneXmm              #   if not aligned, jump to generic handler
    cmp        $0x40, %rax                  # Read is aligned, check num bytes remaining
    jge        .LprocessCacheLinePre        #   if >= 64, jump to cache-line handler

.LprocessOneXmm:
    vmovaps    0x10(%r12,%rdx,1), %xmm4     #
    vpand      %xmm0, %xmm4, %xmm4          #
    vpcmpeqb   %xmm1, %xmm4, %xmm4          #
    vpxor      %xmm2, %xmm4, %xmm4          #
    vpand      %xmm3, %xmm4, %xmm4          #
    vmovaps    %xmm4, 0x10(%r14,%rdx,1)     # 
    add        $0x10, %rdx
    jmp        .LloopStart


    .align 0x10                             # Align jump target to 16-byte boundary

.LprocessCacheLinePre:
#    m_save_regs_avx
#    call       *0xa8(%rsp)
#    m_restore_regs_avx

.LprocessCacheLine:
    vmovaps    0x10(%r12,%rdx,1), %ymm4     #
    vmovaps    0x30(%r12,%rdx,1), %ymm6     #

    prefetcht0 0x310(%r12,%rdx,1)           # Prefetch src cache line 8 loops hence (after movaps above)

    vperm2f128 $0x01, %ymm4, %ymm4, %ymm5   #
    vperm2f128 $0x01, %ymm6, %ymm6, %ymm7   #

    vpand      %xmm0, %xmm4, %xmm4          #
    vpand      %xmm0, %xmm5, %xmm5          #
    vpand      %xmm0, %xmm6, %xmm6          #
    vpand      %xmm0, %xmm7, %xmm7          #

    vpcmpeqb   %xmm1, %xmm4, %xmm4          #
    vpcmpeqb   %xmm1, %xmm5, %xmm5          #
    vpcmpeqb   %xmm1, %xmm6, %xmm6          #
    vpcmpeqb   %xmm1, %xmm7, %xmm7          #

    vpxor      %xmm2, %xmm4, %xmm4          #
    vpxor      %xmm2, %xmm5, %xmm5          #
    vpxor      %xmm2, %xmm6, %xmm6          #
    vpxor      %xmm2, %xmm7, %xmm7          #

    vpand      %xmm3, %xmm4, %xmm4          #
    vpand      %xmm3, %xmm5, %xmm5          #
    vpand      %xmm3, %xmm6, %xmm6          #
    vpand      %xmm3, %xmm7, %xmm7          #
    
    vperm2f128 $0x20, %ymm4, %ymm5, %ymm4   #
    vperm2f128 $0x20, %ymm6, %ymm7, %ymm6   #

    vmovaps    %ymm4, 0x10(%r14,%rdx,1)     # Copy result to output
    vmovaps    %ymm6, 0x30(%r14,%rdx,1)     # 

    add        $0x40, %rdx                  #
    mov        %r15, %rax                   #
    sub        %rdx, %rax                   #
    cmp        $0x40, %rax                  #
    jge        .LprocessCacheLine           #
    m_save_regs_avx
    call       *0xa0(%rsp)
    m_restore_regs_avx
    jmp        .LloopStart                  #

.LsubXmmRemaining:
    vmovaps   0x10(%r12,%rdx,1), %xmm4      # Load 16-bytes of input
    vpand     %xmm0, %xmm4, %xmm4           # compare
    vpcmpeqb  %xmm1, %xmm4, %xmm4           # set to 0xff if equal
    vpxor     %xmm2, %xmm4, %xmm4           # flip bytes
    vpand     %xmm3, %xmm4, %xmm4           # convert 0xff to 0x01
    
    vmovaps   %xmm4, (%rsp)                 # Copy boolean results to stack
    xor       %rbx, %rbx                    # Zero RBX for counting bytes copied
    mov       %r15, %rax                    # Copy veclen(result)
    sub       %rdx, %rax                    # Calc remaining
    cmp       $0x08, %rax                   # Compare remaining with 8
    jl        .LltEightRemaining            #   branch < 8
    movq      (%rsp,%rbx,1), %r8            # Copy QW from stack to QW reg
    movq      %r8, 0x10(%r14,%rdx,1)        # Copy the same to the result
    add       $0x08, %rdx                   # Add 8 to counter
    add       $0x08, %rbx                   # Add 8 to src-counter
    sub       $0x08, %rax                   # Subtract 8 from remaining
.LltEightRemaining:                         # Handle < 8
    cmp       $0x04, %rax                   # Compare remaining with 4
    jl        .LltFourRemaining             #   branch < 4
    movl      (%rsp,%rbx,1), %r8d           # Copy result to DW reg
    movl      %r8d, 0x10(%r14,%rdx,1)       # Copy DW to result
    add       $0x04, %rdx                   # Add 4 to counter
    add       $0x04, %rbx                   # Add 4 to src-counter
    sub       $0x04, %rax                   # Subtract 4 from remaining
.LltFourRemaining:
    cmp       $0x02, %rax
    jl        .LltTwoRemaining
    movw      (%rsp,%rbx,1), %r8w
    movw      %r8w, 0x10(%r14,%rdx,1)       # Copy W to result
    add       $0x02, %rdx                   # Add 2 to counter
    add       $0x02, %rbx                   # Add 2 to src-counter
    sub       $0x02, %rax                   # Subtract 2 from remaining
.LltTwoRemaining:
    cmp       $0x01, %rax
    jl        .LnoneRemaining
    movb      (%rsp,%rbx,1), %r8b
    movb      %r8b, 0x10(%r14,%rdx,1)       # Copy DW to result
.LnoneRemaining:
    jmp       .LsuccessExit

