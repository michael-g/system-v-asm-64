#include <dlfcn.h>
#include <stdlib.h>
#include <stdio.h>

#define KXVER 3
#include "k.h"

extern void start_counters(void);
extern void stop_counters(void);

void execute_test()
{
	void *handle;
	char *error;
	K (*bitwiseOr)(K,K);
	handle = dlopen("libkdbasm.so", RTLD_LAZY);
	if (!handle) {
		krr(dlerror());
		return;
	}
	bitwiseOr = dlsym(handle, "bitwiseOr");
	if ((error = dlerror()) != NULL)  {
		krr("While finding symbol 'bitwiseOr'");
		return;
	}
	
	K byteVec, byteMask, result;
	byteVec = ktn(4, 100000);
	byteMask = kg(1);
	start_counters();
	result = bitwiseOr(byteVec, byteMask);
	stop_counters();
	r0(byteVec);
	r0(byteMask);
	r0(result);
	dlclose(handle);
	return;
}
