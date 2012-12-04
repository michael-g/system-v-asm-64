.section .rodata

.section .text

.globl    main
.type     main, STT_FUNC

main:
    mov        $2, %rax
    movq       %rax, %xmm0

    vpxor      %xmm1, %xmm1, %xmm1      # Clear XMM0: arg[2] = arg[0] ^ arg[1]
    vpshufb    %xmm1, %xmm0, %xmm0      # Byte-wise shuffle: msk=arg[0], val=arg[1], dst=arg[2]; 2B/4-282, p. 284
    vperm2f128 $0, %ymm0, %ymm0, %ymm0  # Copy low DQ word to high DQ word (ignores arg[1])

    vpcmpeqw   %xmm2, %xmm2, %xmm2      # Set all bits in XMM2
    vperm2f128 $0, %ymm2, %ymm2, %ymm2  # Copy to high-DQ Word
    
    vpcmpeqw   %xmm3, %xmm3, %xmm3      # Set all bits in XMM3: 0xffff_ffff_ffff_ffff_...
    vpsrlw     $15, %xmm3, %xmm3        # Rotates by 15 bits:   0x0001_0001_0001_0001_...
    vpackuswb  %xmm3, %xmm3, %xmm3      # Packs:                0x0101_0101_0101_0101_...
    vperm2f128 $0, %ymm3, %ymm3, %ymm3  # Copy to high-DQ Word




    mov        $0x3c, %rax
    xor        %rdi, %rdi
    syscall
