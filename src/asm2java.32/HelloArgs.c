#include "HelloArgs.h"

JNIEXPORT void JNICALL Java_HelloArgs_sayHello (JNIEnv * env, jobject jobj) {
	jclass jclazz = (*env)->FindClass(env, "HelloArgs");
	jmethodID jmid = (*env)->GetMethodID(env, jclazz, "printMessage", "()V");
	(*env)->CallVoidMethod(env, jobj, jmid);
}

JNIEXPORT void JNICALL Java_HelloArgs_multiply(JNIEnv * env, jobject jobj, jint sideLen, jintArray m1, jintArray m2) {
	
}
