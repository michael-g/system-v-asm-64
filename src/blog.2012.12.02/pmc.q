/
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
\

/ load the shared library 'libpmc.so' and assign the 5-arg function 'runtest' to .pmc.runtestdl
/ .mg.or:`libkdbavxor 2:(`mgBitwiseOr;2);
.pmc.runtestdl:`libpmc 2:(`runtest;6);
.pmc.libname:"libkdbsseor.so";

/ load the CSV
.pmc.evt:flip `event`umask`mnemonic`description!("XXS*";",") 0:`:pmcdata.csv
/ initialise the table of absolute flag values
.pmc.flags:([]name:`inv`en`any`int`pc`edg`os`usr;val:{`int$ 2 xexp x}[23 22 21 20 19 18 17 16i])

/ table will contain a set of event combinations accessible through a logical name
.pmc.preset:([]name:`$();syms:();cmask:`int$();flags:());
/ insert a row containing sym-vectors first
`.pmc.preset insert (`dummy;`a`b;0i;`c`d);
`.pmc.preset insert (`UopsP234;`UOPS_DISPATCHED_PORT.PORT_2`UOPS_DISPATCHED_PORT.PORT_3`UOPS_DISPATCHED_PORT.PORT_4;0i;`en);
`.pmc.preset insert (`UopsP015;`UOPS_DISPATCHED_PORT.PORT_0`UOPS_DISPATCHED_PORT.PORT_1`UOPS_DISPATCHED_PORT.PORT_5;0i;`en);
`.pmc.preset insert (`UopsP0;`UOPS_DISPATCHED_PORT.PORT_0;0i;`en);
`.pmc.preset insert (`UopsP1;`UOPS_DISPATCHED_PORT.PORT_1;0i;`en);
`.pmc.preset insert (`UopsP5;`UOPS_DISPATCHED_PORT.PORT_5;0i;`en); / Agner says unreliable PMCTestA.cpp,ln.850
`.pmc.preset insert (`UopsAny;`UOPS_ISSUED.ANY;0i;`en);
`.pmc.preset insert (`L1Miss;`L2_RQSTS.ALL_DEMAND_DATA_RD`L2_RQSTS.ALL_RFO;0i;`en);
`.pmc.preset insert (`L3Miss;`LONGEST_LAT_CACHE.MISS;0i;`en);
`.pmc.preset insert (`L3Hit;`LONGEST_LAT_CACHE.REFERENCE;0i;`en);
`.pmc.preset insert (`BrInstMissRetd;`BR_MISP_RETIRED.ALL_BRANCHES;0i;`en); 
`.pmc.preset insert (`BrInstRetd;`BR_INST_RETIRED.ALL_BRANCHES;0i;`en);
`.pmc.preset insert (`Ring0edg;`CPL_CYCLES.RING0;0i;`en`edg);
`.pmc.preset insert (`PendL2MissLd;`CYCLE_ACTIVITY.CYCLES_L2_PENDING;0i;`en);
`.pmc.preset insert (`StallCycles;`UOPS_DISPATCHED.THREAD;1i;`en`inv);
`.pmc.preset insert (`MemUopsLd;`MEM_UOP_RETIRED.LOADS`MEM_UOP_RETIRED.ALL;0i;`en);
`.pmc.preset insert (`MemUopsSv;`MEM_UOP_RETIRED.STORES`MEM_UOP_RETIRED.ALL;0i;`en);

/
 This function operates on vectors of typed-data, and can be used in a select statement: 
    select .pmc.msrs[col1;col2;col3] from tbl
 Args:
 - mnms: a generic list of symbol-vectors or a symbol atom; determined by the contents of .pmc.preset
 - cmsk: an int-vector
 - flags: a symbol-vector (not a list of symbol-vectors)
\
.pmc.msrs:{[mnms;cmsk;flags]
	msr:{first exec event + 256i * umask from select `int$+/[umask] by event from .pmc.evt where mnemonic in x} each mnms;
	msr+:{16777216i * x} first cmsk;
	msr+:+/[{exec val from .pmc.flags where name in x } each flags];
	:msr
 };

/
 Takes a symbol vector of logical names in the .pmc.preset table, from which it generates the MSR.eax
 values required for the general PMCs. It passes these to .pmc.runtest for execution, and aggregtes
 the results. 
 Args:
 - symvec: vector of symbol-vectors 
 - fccctrl: the IA32_FIXED_CTR_CTRL.eax value
\
.pmc.runscript:{[symvec;domain]
	kv:raze {[x;y] exec name!.pmc.msrs[syms;cmask;raze enlist[y],flags] from .pmc.preset where name=x}[;domain] each symvec;
	result:.pmc.runtest[value kv;domain;2048];
	t:flip (`instAny`clkCore`clkRef,key kv)!result;
	t:update MHz:(`int$ 2700 % clkRef % clkCore), nanos:(`int$clkRef % 2.7) from t;
	:t
 };

/
 Generates a table of values capable of being transcribed into the struct MsrInOut[], and passes
 those values to the shared library.
 Args:
 - evtselv: vector of MSR.eax values, PMC0-3
 - fccctrl: IA32_PERF_FIXED_CTR_CTRL.eax value
 - runct: the number of test iterations to carry out
\
.pmc.runtest:{[evtselv;domain;runct]
	i:0i;
	/ object in which to store MSR values
	msrd:`op`ecx`eax`edx!(`int$();`int$();`int$();`int$());
	/ acculator for enabling individual PMCs
	ctren:0i;
	/ iterate over perf event select int values
	while [ i < count evtselv;
		/ append values 
		msrd[`op],:2;           / MSR_WRITE
		msrd[`ecx],:390i+i;     / 0x186+i (ia32_perfevtselx)
		msrd[`eax],:evtselv[i]; / MSR.eax value calc'd earlier
		msrd[`edx],:0i;
		ctren+:`int$2 xexp i;   / accumulate perf_global_ctrl.eax value
		i+:1i];
	/ perf_fixed_ctr_ctrl - 0x222 enables all three
	msrd[`op],:2;      / MSR_WRITE
	msrd[`ecx],:909i;  / 0x38d
	msrd[`eax],:.pmc.toffcctrl[domain]; 
	msrd[`edx],:0i;
	/ perf_global_ctrl 
	msrd[`op],:2;      / MSR_WRITE
	msrd[`ecx],:911i;  / 0x38f
	msrd[`eax],:ctren; / PMC-enable value
	msrd[`edx],:7i;    / enable FFCs
	if [ 10 <> type .pmc.libname ; 'libname ];
	/ Execute test through the shared library
	result:.pmc.runtestdl[msrd`op; msrd`ecx; msrd`eax; msrd`edx; runct; .pmc.libname];
	/ Explictly return result
	:result
 };
/ 
  calculates the value to write to IA32_FIXED_CTR_CTRL.eax from a symbol-vector of possible values 
  `os`usr 
\
.pmc.toffcctrl:{
	+/[256 16 1 * exec +/[val] from ([]name:`os`usr;val:1 2) where name in x]
 };
/ canned script 1
.pmc.script1:{[domain]
	.pmc.runscript[`UopsAny`UopsP015`UopsP234`L3Miss;domain]
 };
/ canned script 2
.pmc.script2:{[domain]
	.pmc.runscript[`UopsAny`L1Miss`L3Miss`StallCycles;domain]
 };
/ canned script 3
.pmc.script3:{[domain]
	.pmc.runscript[`PendL2MissLd`L1Miss`L3Miss`L3Hit;domain]
 };
/ canned script 4
.pmc.script4:{[domain]
	.pmc.runscript[`UopsAny`MemUopsLd`L3Miss`StallCycles;domain]
 };
system "c 45 191";
