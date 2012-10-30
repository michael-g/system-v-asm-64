
.pmc.runtestdl:`libpmc 2:(`runtest;5);
.pmc.evt:flip `event`umask`mnemonic`description!("XXS*";",") 0:`:pmcdata.csv
.pmc.flags:([]name:`inv`en`int`pc`edg`os`usr;val:{`int$ 2 xexp x}[23 22 20 19 18 17 16i])

.pmc.msrs:{[mnms;cmsk;flags]
	msr:{first exec event + 256i * umask from select `int$+/[umask] by event from .pmc.evt where mnemonic in x} each mnms;
	msr+:{16777216i * x} each cmsk;
	msr+:{+/[exec val from .pmc.flags where name in x]} each flags;
	:msr
 };

.pmc.runscript:{[symvec]
	kv:raze {exec name!.pmc.msrs[syms;cmask;flags] from .pmc.preset where name=x} each symvec;
	result:.pmc.runtest[value kv;32];
	t:flip (`instAny`clkCore`clkRef,key kv)!result;
	t:update mHz:`int$ 2700 % clkRef % clkCore from t;
	:t
 };

.pmc.runtest:{[evtselv;runct]
	i:0i;
	/ object in which to store MSR values
	msrd:`op`ecx`eax`edx!(`int$();`int$();`int$();`int$());
	/ acculator for enabling individual PMCs
	ctren:0i;
	/ iterate over perf event select int values
	while [ i < count evtselv;
		msrd[`op],:2;
		msrd[`ecx],:390i+i; / 0x186
		msrd[`eax],:evtselv[i];
		msrd[`edx],:0i;
		ctren+:`int$2 xexp i;
		i+:1i];
	/ perf_fixed_ctr_ctrl - 0x222 enables all three
	msrd[`op],:2;
	msrd[`ecx],:909i; / 0x38d
	msrd[`eax],:546i; / 0x222
	msrd[`edx],:0i;
	/ perf_global_ctrl - ecx:0x38f; eax:PMCs; edx:FFCs
	msrd[`op],:2;
	msrd[`ecx],:911i;
	msrd[`eax],:ctren;
	msrd[`edx],:7i;
	result:.pmc.runtestdl[msrd`op; msrd`ecx; msrd`eax; msrd`edx; runct];
	:result
 };

.pmc.script1:{
	.pmc.runscript[`UopsAny`UopsP015`UopsP234`L3Miss]
 };
.pmc.script2:{
	.pmc.runscript[`NA0`Instns`NA2`NA3] / the `Instns PMC must be run on PMC1 only
 };
.pmc.script3:{
	.pmc.runscript[`L1Miss`L3Miss`BrMispred`UopsAny]
 };

.pmc.init:{
	.pmc.preset:([]name:`$();syms:();cmask:`int$();flags:());
	/ insert row containing sym-vectors first
	`.pmc.preset insert (`UopsP234;`UOPS_DISPATCHED_PORT.PORT_2`UOPS_DISPATCHED_PORT.PORT_3`UOPS_DISPATCHED_PORT.PORT_4;0i;`en`usr);
	`.pmc.preset insert (`UopsP015;`UOPS_DISPATCHED_PORT.PORT_0`UOPS_DISPATCHED_PORT.PORT_1`UOPS_DISPATCHED_PORT.PORT_5;0i;`en`usr);
	`.pmc.preset insert (`UopsP0;`UOPS_DISPATCHED_PORT.PORT_0;0i;`en`usr);
	`.pmc.preset insert (`UopsP1;`UOPS_DISPATCHED_PORT.PORT_1;0i;`en`usr);
	`.pmc.preset insert (`UopsP5;`UOPS_DISPATCHED_PORT.PORT_5;0i;`en`usr); / Agner says unreliable PMCTestA.cpp,l.850
	`.pmc.preset insert (`UopsAny;`UOPS_ISSUED.ANY;0i;`en`usr);
	`.pmc.preset insert (`Instns;`INST_RETIRED.ALL;0i;`en`usr);            / "PMC1 only; Must quiesce other PMCs."
	`.pmc.preset insert (`L1Miss;`L2_RQSTS.ALL_DEMAND_DATA_RD`L2_RQSTS.ALL_RFO;0i;`en`usr);
	`.pmc.preset insert (`L3Miss;`LONGEST_LAT_CACHE.MISS;0i;`en`usr);
	`.pmc.preset insert (`NA0;`UOPS_ISSUED.ANY;0i;`NA);
	`.pmc.preset insert (`NA1;`UOPS_ISSUED.ANY;0i;`NA);
	`.pmc.preset insert (`NA2;`UOPS_ISSUED.ANY;0i;`NA);
	`.pmc.preset insert (`NA3;`UOPS_ISSUED.ANY;0i;`NA);
	`.pmc.preset insert (`BrMispred;`BR_MISP_RETIRED.ALL_BRANCHES;0i;`en`usr); 
 };

.pmc.init[];
system "c 45 191";

\
.pmc.msr:{[mnms;cmsk;flags]
	msr:first exec event + 256i * umask from select `int$+/[umask] by event from .pmc.evt where mnemonic in mnms mnms;
	msr+:16777216i * cmsk;
	msr+:+/[exec val from .pmc.flags where name in raze flags];
	:msr
 };

