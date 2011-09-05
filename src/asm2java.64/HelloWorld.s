.section .data

clazz_name:
        .asciz  "HelloWorld"
void_sig:
        .asciz  "()V"
method_name:
        .asciz  "sayHello"
        
.section .text

        .globl  Java_HelloWorld_requestGreeting
        .type   Java_HelloWorld_requestGreeting, @function

Java_HelloWorld_requestGreeting:

        #
        # Prologue
        #
        pushq   %rbp
        movq    %rsp, %rbp                # Store the two arguments to the function

        #
        # JNIEXPORT void JNICALL Java_HelloWorld_sayHello(JNIEnv*, jobject);
        # Parameters:
        #     RDI: JNIEnv*
        #     RSI: jobject
        #
        # The stack frame we inherit and subsequently intend to set-up will look like this:
        #   8      -> return address
        #  -0(RBP) -> previous RBP
        #  -8      -> JNIEnv parameter
        # -16      -> jobject parameter
        # -24      -> The address of the JNI function-table (to be calculated)
        # -32      -> The result of the call to FindClass (to be retrieved)
        # -40      -> The result of the call to GetMethodID (to be retrieved)
        #
        subq    $40, %rsp                 # Reserve the stack frame

        movq    %rdi, -8(%rbp)            # Store the JNIEnv parameter on the stack
        movq    %rsi, -16(%rbp)           # Store the jobject parameter on the stack
        
        movq    (%rdi), %rax              # RAX now contains the starting address of the function-table.
        movq    %rax, -24(%rbp)           # Store function-table address on the stack
        
        #
        # Invoke the (*JNIEnv)->FindClass function to look-up the address of the function-table
        # for the class "HelloWorld"
        # Parameters:
        #     RDI: JNIEnv*
        #     RSI: address-of "HelloWorld"
        # Returns:
        #     JClass*
        #
                                          # RDI still contains pointer to JNIEnv
        leaq    clazz_name(%rip), %rsi    # Calculate and store the address of "HelloWorld" in RSI

        movq    48(%rax), %rax            # Store the address of the 6th element in the function-table in RAX
        call    *%rax                     # Call resulting function-pointer; it returns a pointer to the JClass in RAX
        
        movq    %rax, -32(%rbp)           # Store result on the stack
        
        # 
        # Invoke (*JNIEnv)->GetMethodID function
        # Parameters:
        #     RDI: JNIEnv*
        #     RSI: JClass*
        #     RDX: address-of "sayHello"
        #     RCX: address-of "()V", the "void" parameter-list descriptor
        # Returns:
        #     jmethodID*
        #
        movq    -8(%rbp), %rdi            # Retrieve pointer to JNIEnv from the stack and store in RDI
        movq    %rax, %rsi                # Store JClass pointer in RSI 
        leaq    void_sig(%rip), %rcx      # Store address of "()V" in RCX
        leaq    method_name(%rip), %rdx   # Store address of "sayHello" in RDX
        
        movq    -24(%rbp), %rax           # Look-up the pointer to the function-table from the stack and store in RAX
        movq    264(%rax), %rax           # Store the address of the 33rd element (GetMethodID) in RAX
        call    *%rax                     # Call function-pointer; it returns a pointer to the jmethodID
        
        movq    %rax, -40(%rbp)           # Store the jmethodID on the stack
        
        #
        # Invoke (*env)->CallVoidMethod 
        # Parameters:
        #     RDI: JNIEnv*
        #     RSI: jobject*
        #     RDX: jmethodID*
        #      AL: varargs parameter count
        # Returns:
        #     void
        movq    -8(%rbp), %rdi            # Retrieve pointer to JNIEnv from the stack and store in RDI
        movq    -16(%rbp), %rsi           # Retrieve pointer to JObject from the stack and store in RSI
        movq    %rax, %rdx                # Store pointer to jmethodID in RDX
        
        movq    -24(%rbp), %rax           # Look-up the pointer to the function-table from the stack and store in RAX
        movq    488(%rax), %rcx           # Store the address of the 61st element (CallVoidMethod) in _RCX_
        xorq    %rax, %rax                # Set RAX (and hence AL) to zero. See page 20 of the SysV ABI and notes below
        call    *%rcx
        
        #
        # Epilogue
        #
        movq    %rbp, %rsp                # forget stack frame
        popq    %rbp                      # restore caller's base-pointer

        retq
        