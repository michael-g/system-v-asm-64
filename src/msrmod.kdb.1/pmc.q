/ load the shared library 'libpmc.so' and assign the 5-arg function 'runtest' to .pmc.runtestdl
.pmc.runtestdl:`libpmc 2:(`runtest;5);
/ load the CSV
.pmc.evt:flip `event`umask`mnemonic`description!("XXS*";",") 0:`:pmcdata.csv
/ initialise the table of absolute flag values
.pmc.flags:([]name:`inv`en`any`int`pc`edg`os`usr;val:{`int$ 2 xexp x}[23 22 21 20 19 18 17 16i])

/ table will contain a set of event combinations accessible through a logical name
.pmc.preset:([]name:`$();syms:();cmask:`int$());
/ insert a row containing sym-vectors first
`.pmc.preset insert (`UopsP234;`UOPS_DISPATCHED_PORT.PORT_2`UOPS_DISPATCHED_PORT.PORT_3`UOPS_DISPATCHED_PORT.PORT_4;0i);
`.pmc.preset insert (`UopsP015;`UOPS_DISPATCHED_PORT.PORT_0`UOPS_DISPATCHED_PORT.PORT_1`UOPS_DISPATCHED_PORT.PORT_5;0i);
`.pmc.preset insert (`UopsP0;`UOPS_DISPATCHED_PORT.PORT_0;0i);
`.pmc.preset insert (`UopsP1;`UOPS_DISPATCHED_PORT.PORT_1;0i);
`.pmc.preset insert (`UopsP5;`UOPS_DISPATCHED_PORT.PORT_5;0i); / Agner says unreliable PMCTestA.cpp,l.850
`.pmc.preset insert (`UopsAny;`UOPS_ISSUED.ANY;0i);
`.pmc.preset insert (`L1Miss;`L2_RQSTS.ALL_DEMAND_DATA_RD`L2_RQSTS.ALL_RFO;0i);
`.pmc.preset insert (`L3Miss;`LONGEST_LAT_CACHE.MISS;0i);
`.pmc.preset insert (`BrMispred;`BR_MISP_RETIRED.ALL_BRANCHES;0i); 

/
 This function operates on vectors of typed-data, and can be used in a select statement: 
    select .pmc.msrs[col1;col2;col3] from tbl
 Args:
 - mnms: a list of symbol-vectors (.pmc.evt mnemonics)
 - cmsk: a list of int-vectors 
 - flags: a list of symbol-vectors (corresponding to the values in .pmc.flags)
\
.pmc.msrs:{[mnms;cmsk;flags]
	msr:{first exec event + 256i * umask from select `int$+/[umask] by event from .pmc.evt where mnemonic in x} each mnms;
	msr+:{16777216i * x} each cmsk;
	msr+:+/[exec val from .pmc.flags where name in flags];
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
	kv:raze {[x;y] exec name!.pmc.msrs[syms;cmask;raze enlist[y],`en] from .pmc.preset where name=x}[;domain] each symvec;
	result:.pmc.runtest[value kv;domain;32];
	t:flip (`instAny`clkCore`clkRef,key kv)!result;
	t:update mHz:`int$ 2700 % clkRef % clkCore from t;
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
	/ Execute test through the shared library
	result:.pmc.runtestdl[msrd`op; msrd`ecx; msrd`eax; msrd`edx; runct];
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
/ canned script to execute the test with each of `UopsAny`UopsP015`UopsP234`L3Miss
.pmc.script1:{[domain]
	.pmc.runscript[`UopsAny`UopsP015`UopsP234`L3Miss;domain]
 };
/ canned script to execute the test with each of `L1Miss`L3Miss`BrMispred`UopsAny
.pmc.script2:{[domain]
	.pmc.runscript[`L1Miss`L3Miss`BrMispred`UopsAny;domain]
 };

system "c 45 191";

