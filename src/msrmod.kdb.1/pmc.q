
.pmc.runtestdl:`libpmc 2:(`runtest;5);
.pmc.evt:flip `event`umask`mnemonic`description!("XXS*";",") 0:`:pmcdata.csv
.pmc.flags:([]name:`inv`en`int`pc`edg`os`usr;val:{`int$ 2 xexp x}[23 22 20 19 18 17 16i])

.pmc.orUmask:{[s] 
	+/[exec umask from t where mnemonic in s]
 };

.pmc.msr:{[mnms;cmsk;flags]
	msr:first exec event + 256i * umask from select `int$+/[umask] by event from .pmc.evt where mnemonic in mnms;
	msr+:16777216i * cmsk;
	msr+:+/[exec val from .pmc.flags where name in flags];
	:msr
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

.pmc.init:{
	pmcs:();
	pmcs,:.pmc.msr[ `UOPS_ISSUED.ANY;0i;`en`usr];
	pmcs,:.pmc.msr[ `LONGEST_LAT_CACHE.MISS;0i;`en`usr];
	pmcs,:.pmc.msr[ `UOPS_DISPATCHED_PORT.PORT_0;0i;`en`usr];
	pmcs,:.pmc.msr[ `UOPS_DISPATCHED_PORT.PORT_5;0i;`en`usr];
	result:.pmc.runtest[pmcs;32];
	:flip `inst.any`clk.core`clk.ref`uops.any`llc.miss`uops.p0`uops.p5!result
 };
