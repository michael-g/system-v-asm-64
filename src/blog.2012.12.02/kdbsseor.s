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
    .align    0x10                            # Align LbadTypeStr to 16-byte boundary
.LbadTypeStr:
    .asciz    "vectype"

.section .text
    .globl    mgBitwiseOr                     # Declare global function 'mgBitwiseOr'
    .type     mgBitwiseOr, STT_FUNC 

.LbadType:                                    # Handler for invalid input vector-type
    lea          .LbadTypeStr(%rip), %rdi     # Load address of error message
    callq        krr@PLT                      # Call kdb's error function
    jmp          .LrestoreStackForExit        # Exit via the clean-up function

.LsuccessExit:
    mov       %r14, %rax                      # Copy result address to RAX
.LrestoreStackForExit:
    mov       %rbp, %rsp                      # Restore poppable SP
    pop       %r15                            # Restore non-volatile registers
    pop       %r14
    pop       %r13
    pop       %r12
    pop       %rbx
    pop       %rbp
    ret                                       # Exit to calling code

mgBitwiseOr:
    push      %rbp                            # Push all non-volatile registers
    push      %rbx
    push      %r12
    push      %r13
    push      %r14
    push      %r15
    mov       %rsp, %rbp                      # Store updated SP
    sub       $0x10, %rsp                     # Reserve stack space
    and       $~0xF, %rsp                     # Align to 16-byte boundary
    push      %rdx                            # Store arg2: start_counters address: 0x08(%rsp)
    push      %rcx                            # Store arg3: stop_counters address:  0x00(%rsp)

    mov       %rdi, %r12                      # Save arg0: byte-vec
    mov       %rsi, %r13                      # Save arg1: byte-mask

    movb      2(%rdi), %al                    # Copy arg0->t to lo-byte
    mov       %al, %bl                        # Copy type
    sub       $4, %bl                         # Check lower-bound
    jl        .LbadType                       # Branch if below
    sub       $4, %al                         # Check upper-bound
    jg        .LbadType                       # Branch if above

    # Create result object
    mov       $1, %rdi                        # Specify type (bool-vec)
    movq      8(%r12), %rsi                   # Copy veclen(arg0)
    callq     ktn@PLT                         # Create result struct
    mov       %rax, %r14                      # Store result address in non-vol register

.LpreLoopByte:
    # shuffle mask byte into all 128 bits of XMM
    xor       %rax, %rax                      # zero register
    movb      8(%r13), %al                    # load mask-byte, arg1->g
    movq      %rax, %xmm0                     # copy byte to XMM
    pxor      %xmm1, %xmm1                    # clear mask bytes
    pshufb    %xmm1, %xmm0                    # XMM0 contains 16 copies of arg1->g
    pcmpeqw   %xmm2, %xmm2                    # set all bits

    # Initialise 0xFF->0x01 conversion mask
    pcmpeqw   %xmm3, %xmm3                    # Generates: 0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff
    psrlw     $15, %xmm3                      # Rotates:   0x0001_0001_0001_0001_0001_0001_0001_0001
    packuswb  %xmm3, %xmm3                    # Packs:     0x0101_0101_0101_0101_0101_0101_0101_0101

    movq      8(%r14), %r15                   # Copy veclen(result) -> R15
    xor       %rdx, %rdx                      # Clear counter

.LloopByte:
    mov       %r15, %rax                      # Copy vec-len
    sub       %rdx, %rax                      # Calculate remaining
    jle       .LsuccessExit                   #   branch to exit if <= 0
    cmp       $0x10, %rax                     # Compare remaining with 16
    jl        .LsubXmmRemaining               #   branch if < 16 
    je        .LsingleReg                     #   branch if == 16
    lea       0x10(%r12,%rdx), %rbx           # Load address of next read
    test      $0x3f, %rbx                     # Test for 64-byte alignment
    jnz       .LsingleReg                     #   if not aligned, jump to generic handler
    cmp       $0x40, %rax                     # Read is aligned, check num bytes available
#        jge       .LquadReg                  #   if >= 64, handle 64-bytes at a time
    jge       .LquadRegPre                    #   if >= 64, handle 64-bytes at a time


.LsingleReg:
    movaps    0x10(%r12,%rdx,1), %xmm4        # Load 16-bytes of input
    pand      %xmm0, %xmm4                    # compare with mask
    pcmpeqb   %xmm1, %xmm4                    # set to 0xFF if equal
    pxor      %xmm2, %xmm4                    # flip bits
    pand      %xmm3, %xmm4                    # convert 0xFF to 0x01
    movaps    %xmm4, 0x10(%r14,%rdx,1)        # Given >= 16 bytes, copy result
    add       $0x10, %rdx
    jmp       .LloopByte

.LquadRegPre:
    m_save_regs
    call      *0xa8(%rsp)
    m_restore_regs
.LquadReg:
    movaps    0x10(%r12,%rdx,1), %xmm4        # Copy cache line into registers
    movaps    0x20(%r12,%rdx,1), %xmm5
    movaps    0x30(%r12,%rdx,1), %xmm6
    movaps    0x40(%r12,%rdx,1), %xmm7

    prefetcht0 0x210(%r12,%rdx,1)             # Prefetch src cache line 8 loops hence (after movaps above)

    pand      %xmm0, %xmm4                    # Bitwise-AND 16-byte value against the vectorised byte-mask
    pand      %xmm0, %xmm5
    pand      %xmm0, %xmm6
    pand      %xmm0, %xmm7

    pcmpeqb   %xmm1, %xmm4                    # Compare byte-values with zero, each now 0xFF or 0x00
    pcmpeqb   %xmm1, %xmm5
    pcmpeqb   %xmm1, %xmm6
    pcmpeqb   %xmm1, %xmm7

    pxor      %xmm2, %xmm4                    # Flip bytes using an operand with all bits set
    pxor      %xmm2, %xmm5
    pxor      %xmm2, %xmm6
    pxor      %xmm2, %xmm7

    pand      %xmm3, %xmm4                    # Filter bits so those set 0xFF now equal 0x01
    pand      %xmm3, %xmm5
    pand      %xmm3, %xmm6
    pand      %xmm3, %xmm7

    movaps    %xmm4, 0x10(%r14,%rdx,1)        # Copy result to output
    movaps    %xmm5, 0x20(%r14,%rdx,1)
    movaps    %xmm6, 0x30(%r14,%rdx,1)
    movaps    %xmm7, 0x40(%r14,%rdx,1)

    add       $0x40, %rdx                     # Add 64 to counter
    mov       %r15, %rax                      # Copy veclen
    sub       %rdx, %rax                      # Subtract counter from veclen
    cmp       $0x40, %rax                     # Compare remainder against 64 bytes
    jge       .LquadReg                       #   if >= 64, repeat aligned branch
    m_save_regs
    call      *0xa0(%rsp)
    m_restore_regs
    jmp       .LloopByte                      # Branch to generic loop

.LsubXmmRemaining:
    movaps    0x10(%r12,%rdx,1), %xmm4        # Load 16-bytes of input
    pand      %xmm0, %xmm4                    # compare
    pcmpeqb   %xmm1, %xmm4                    # set to 0xff if equal
    pxor      %xmm2, %xmm4                    # flip bytes
    pand      %xmm3, %xmm4                    # convert 0xff to 0x01
    
    movaps    %xmm4, (%rsp)                   # Copy boolean results to stack
    xor       %rbx, %rbx                      # Zero RBX for counting bytes copied
    mov       %r15, %rax                      # Copy veclen(result)
    sub       %rdx, %rax                      # Calc remaining
    cmp       $0x08, %rax                     # Compare remaining with 8
    jl        .LltEightRemaining              #   branch < 8
    movq      (%rsp,%rbx,1), %r8              # Copy QW from stack to QW reg
    movq      %r8, 0x10(%r14,%rdx,1)          # Copy the same to the result
    add       $0x08, %rdx                     # Add 8 to counter
    add       $0x08, %rbx                     # Add 8 to src-counter
    sub       $0x08, %rax                     # Subtract 8 from remaining
.LltEightRemaining:                           # Handle < 8
    cmp       $0x04, %rax                     # Compare remaining with 4
    jl        .LltFourRemaining               #   branch < 4
    movl      (%rsp,%rbx,1), %r8d             # Copy result to DW reg
    movl      %r8d, 0x10(%r14,%rdx,1)         # Copy DW to result
    add       $0x04, %rdx                     # Add 4 to counter
    add       $0x04, %rbx                     # Add 4 to src-counter
    sub       $0x04, %rax                     # Subtract 4 from remaining
.LltFourRemaining:
    cmp       $0x02, %rax
    jl        .LltTwoRemaining
    movw      (%rsp,%rbx,1), %r8w
    movw      %r8w, 0x10(%r14,%rdx,1)         # Copy W to result
    add       $0x02, %rdx                     # Add 2 to counter
    add       $0x02, %rbx                     # Add 2 to src-counter
    sub       $0x02, %rax                     # Subtract 2 from remaining
.LltTwoRemaining:
    cmp       $0x01, %rax
    jl        .LnoneRemaining
    movb      (%rsp,%rbx,1), %r8b
    movb      %r8b, 0x10(%r14,%rdx,1)         # Copy DW to result
.LnoneRemaining:
    jmp       .LsuccessExit

