.section .data

clazz_name:
	.asciz	"HelloArgs"
void_sig:
	.asciz	"()V"
method_name:
	.asciz	"printMessage"
	
.section .text
#
#  JNIEXPORT void JNICALL Java_HelloArgs_sayHello(JNIEnv *, jobject);
#

	.globl	Java_HelloArgs_sayHello
	.type	Java_HelloArgs_sayHello, @function

Java_HelloArgs_sayHello:

	#
	# Prologue
	#
	pushq	%rbp
	movq	%rsp, %rbp		# Store the two arguments to the function

	#   8      -> return address
	#  -0(RBP) -> previous RBP
	#  -8      -> JNIEnv parameter
	# -16      -> JObject parameter
	# -24      -> Starting address of the Function Table
	# -32      -> The result of the call to FindClass
	# -40      -> The result of the call to GetMethodID
	#
	subq	$40, %rsp		# Allocate stack frame, setting RSP

	movq	%rdi, -8(%rbp)		
	movq	%rsi, -16(%rbp)		
	
	
	movq	(%rdi), %rax		# RAX now contains the starting address of the function table.
	movq	%rax, -24(%rbp)		# Store Function Table address on the stack
	
	#                                   RDI, RSI
	# jclass jclazz = (*env)->FindClass(env, "HelloArgs");
	
	leaq	clazz_name(%rip), %rsi	# Use LEA & relative addressing to load address of "HelloArgs" into RSI
					# RDI still contains pointer to JNIEnv
	movq	48(%rax), %rax		# RAX now contains the address of the "FindClass" function (index 6)
	call	*%rax			# Call FindClazz: returns address of jclass object
	
	movq	%rax, -32(%rbp)		# Store result on the stack
	
	#                                      RDI  RSI,    RDX,            RCX
	# jmethodID jmid = (*env)->GetMethodID(env, jclazz, "printMessage", "()V");
	leaq	void_sig(%rip), %rcx	# Address of "()V"; NB use of LEAQ
	leaq	method_name(%rip), %rdx	# Address of "printMessage"; NB use of LEAQ
	movq	%rax, %rsi		# Take advantage of unchanged value of the return value from FindClazz to put the 'jmid' param into RSI
	movq	-8(%rbp), %rdi		# Copy original pointer-value of JNIEnv into RDI
	
	movq	-24(%rbp), %rax		# Get address of function table
	movq	264(%rax), %rax		# Put address of GetMethodID in RAX (index 33)
	call	*%rax
	
	movq	%rax, -40(%rbp)		# Store the jmethodID on the stack
	
	#                        RDI  RSI,  RDX
	# (*env)->CallVoidMethod(env, jobj, jmid);
	
	movq	%rax, %rdx		# Copy jmethodID into RDX
	movq	-16(%rbp), %rsi		# Copy 2nd parameter to sayHello into RSI from stack 
	movq	-8(%rbp), %rdi		# Copy 1st parameter to sayHello into RDI from stack
	
	movq	-24(%rbp), %rax		# Get address of function table
	movq	488(%rax), %rcx		# Put the address of CallVoidMethod in RCX. ??? WHY NOT RAX ??? (index 61)
	movl	$0, %eax		# WHY ZERO EAX??? See page 20 of the SysV ABI and excerpt below!
	call	*%rcx
	
	#
	# SysV ABI, p20: For calls that may call functions that use varargs or stdargs (prototype-less
	# calls or calls to functions containing ellipsis (...) in the declaration) %al is used
	# as hidden argument to specify the number of vector registers used. The contents of %al do 
	# not need to match exactly the number of registers, but must be an upper bound on the number 
	# of vector registers used and is in the range 0-8 inclusive.
	#
	
	#
	# Epilogue
	#
	movq	%rbp, %rsp		# clear stack frame
	popq	%rbp			# 

	retq
	
	
#
# Whenever a Java program calls a native method, the called method compulsorily receives two 
# parameters in addition to those specified by the calling method. The first is the JNIEnv pointer 
# and the second is a reference to the calling object or class. It is the first parameter that is 
# the key to the world of JNI.
#

#
# "The JNIEnv Interface pointer" http://java.sun.com/docs/books/jni/html/design.html#8371
#
# JNIEnv is a pointer that, in turn, points to another pointer. This second pointer points to a 
# function table that is an array of pointers. Each pointer in the function table points to a JNI 
# interface function. The virtual machine is guaranteed to pass the same interface pointer to native 
# method implementation functions called from the same thread. However, a native method can be called 
# from different threads, and therefore may be passed different JNIEnv interface pointers. Although
# the interface pointer is thread-local, the doubly indirected JNI function table is shared among 
# multiple threads.

# In order to call an interface function, we have to determine the value of 
# the corresponding entry in the function table. 
#

#
# I think this is what it boils down to:
#	JNIEnv pointer %RDI -> Intermediate pointer 0x0(%RDI)-> Function table 0x0(0x0(%RDI))
#
# RDI:     0x12345
# ...
# 0x12345: 0x54321
# ... 
# 0x54321: Function[0]
#


#
# To retrieve the contents of the entry in the function table that corresponds to the function we 
# want to call, we have to multiply the zero based index of the function (see Sheng Liang's book
# http://java.sun.com/docs/books/jni/html/jniTOC.html) by eight, since each pointer is eigth bytes 
# long, and add the result to the starting address of the function table which we have formed in 
# RAX earlier.
#

#
# The function index in the array of pointers can be found here: 
#  http://java.sun.com/docs/books/jni/html/functions.html#70415
#

