
#include "HelloWorld.h"

JNIEXPORT void JNICALL Java_HelloWorld_requestGreeting(JNIEnv* env, jobject hw_obj) {
	jclass clazz = (*env)->FindClass(env, "HelloWorld");
	jmethodID mid = (*env)->GetMethodID(env, clazz, "sayHello", "()V");
	(*env)->CallVoidMethod(env, hw_obj, mid);
}
