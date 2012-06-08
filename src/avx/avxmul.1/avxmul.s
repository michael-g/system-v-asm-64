.section .rodata
        .align 0x20
arr0:
        .double 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31
arr1:
        .double 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32

.section .bss
        .align 0x20
        .lcomm  result, 0x80

.section .text
        .globl main
main:
        sub          $0x40, %rsp
        call         __main

#	.byte 0x0F, 0x0B
#	movl $111, %ebx
#	.byte 0x64, 0x67, 0x90

        leaq         arr0, %rbx
        leaq         arr1, %rdi
        leaq         result, %rdx

        vmovapd      (%rdi), %ymm0                       # load 2, 4, 6, 8

        vbroadcastsd 0x00(%rbx), %ymm1                   # load 1, 1, 1, 1
        vmulpd       %ymm1, %ymm0, %ymm12                # mul  2, 4, 6, 8     = 2, 4, 6, 8

        vbroadcastsd 0x20(%rbx), %ymm1                   # load 9, 9, 9, 9
        vmulpd       %ymm1, %ymm0, %ymm13                # mul  2, 4, 6, 8     = 18, 36, 54, 72

        vbroadcastsd 0x40(%rbx), %ymm1                   # load 17, 17, 17, 17
        vmulpd       %ymm1, %ymm0, %ymm14                # mul   2,  4,  6,  8 = 34, 68, 102, 136

        vbroadcastsd 0x60(%rbx), %ymm1                   # load 25, 25, 25, 25
        vmulpd       %ymm1, %ymm0, %ymm15                # mul   2,  4,  6,  8 = 50, 100, 150, 200
        
        xor          %rax, %rax
        mov          $0x03, %rcx
.Lstart:
        inc          %rax
        add          $0x20, %rdi
        add          $0x20, %rdx

        vmovapd      (%rdi), %ymm0                       # On pass 1, load 10, 12, 14, 16

        vbroadcastsd 0x00(%rbx, %rax, 0x08), %ymm1       # load  3,  3,  3,  3
        vmulpd       %ymm1, %ymm0, %ymm2                 # mul  10, 12, 14, 16 = 30, 36, 42, 48
        vaddpd       %ymm2, %ymm12, %ymm12               # add   2,  4,  6,  8 = 32, 40, 48, 56

        vbroadcastsd 0x20(%rbx, %rax, 0x08), %ymm1       # load 11, 11, 11, 11
        vmulpd       %ymm1, %ymm0, %ymm2                 # mul  10, 12, 14, 16 = 110, 132, 154, 176
        vaddpd       %ymm2, %ymm13, %ymm13               # add  18, 36, 54, 72 = 128, 168, 208, 248

        vbroadcastsd 0x40(%rbx, %rax, 0x08), %ymm1       # load 19, 19,  19,  19
        vmulpd       %ymm1, %ymm0, %ymm2                 # mul  10, 12,  14,  16 = 190, 228, 266, 304
        vaddpd       %ymm2, %ymm14, %ymm14               # add  34, 68, 102, 136 = 224, 296, 368, 440

        vbroadcastsd 0x60(%rbx, %rax, 0x08), %ymm1       # load 27,  27,  27,  27
        vmulpd       %ymm1, %ymm0, %ymm2                 # mul  10,  12,  14,  16 = 270, 324, 378, 432
        vaddpd       %ymm2, %ymm15, %ymm15               # add  50, 100, 150, 200 = 320, 424, 528, 632

        dec          %rcx
        cmp          $0x00, %rcx
        jnz          .Lstart
        
        vmovapd      %ymm12, 0x00+result                 # Write the result to memory. Check in GDB using
        vmovapd      %ymm13, 0x20+result                 # x/16fg &result
        vmovapd      %ymm14, 0x40+result
        vmovapd      %ymm15, 0x60+result
        
#	movl $222, %ebx
#	.byte 0x64, 0x67, 0x90
#	.byte 0x0F, 0x0B

        add          $0x40, %rsp
        xor          %rax, %rax
        ret

