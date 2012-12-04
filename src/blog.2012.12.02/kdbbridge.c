/*
 (c) Michael Guyver, 2012, all rights reserved. Permission to use, copy, modify and distribute the 
 software is hereby granted for educational use which is non-commercial in nature, provided that 
 this copyright  notice and following two paragraphs are included in all copies, modifications and 
 distributions.

 THIS SOFTWARE AND DOCUMENTATION IS PROVIDED "AS IS," AND NO REPRESENTATIONS OR WARRANTIES ARE 
 MADE, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO, WARRANTIES OF MERCHANTABILITY OR 
 FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE SOFTWARE OR DOCUMENTATION WILL NOT 
 INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.

 COPYRIGHT HOLDERS WILL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL OR CONSEQUENTIAL DAMAGES 
 ARISING OUT OF ANY USE OF THE SOFTWARE OR DOCUMENTATION.
*/
#define KXVER 3
#include "k.h"

extern K mgBitwiseOr(K byteVec, K byteMask, void(s1)(void), void(s2)(void));

void execute_test(void (start_counters)(void), void (stop_counters)(void))
{
	K byteVec, byteMask, result;
	byteVec = ktn(4, 1000000);
	byteMask = kg(1);
	result = mgBitwiseOr(byteVec, byteMask, start_counters, stop_counters);
	r0(byteVec);
	r0(byteMask);
	r0(result);
	return;
}
