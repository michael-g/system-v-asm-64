#!/bin/sh
# cf http:/tech.ryancox.net/2011/02/extrapolating-benchmark-scores-using.html

for cpu in /dev/cpu/[0-9]* ; do
	cpu=$(basename ${cpu})
	wrmsr -p${cpu} 0xe8 0
	wrmsr -p${cpu} 0xe7 0
done

sleep 60

tuple=$(rdmsr -p0 -d 0xCE)

refmhz=$(( ((tuple>>8) & 0xFF) * 100 ))

for cpu in /dev/cpu/[0-9]* ; do
	cpu=$(basename ${cpu})
	ratio=$(echo "scale=5; $(rdmsr -p${cpu} -d 0xe8) / $(rdmsr -p${cpu} -d 0xe7)" | bc)
	echo "CPU ${cpu} APERF/MPERF ratio is ${ratio}; ref MHz is ${refmhz} ; ratio * ref is $(echo "scale=5; $refmhz * $ratio" | bc)"
done 
