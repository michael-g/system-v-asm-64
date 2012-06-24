#!/bin/bash

psm=$(pwd)/proc_self_maps.txt
if [ ! -r ${psm} ] ; then
	echo "Cannot find ${psm}. Exiting." >&2
	exit 1
fi

function getseg {
	awk '/'$1'.*libreloc.so/ {split($1,myarr,"-");print myarr[1];}' proc_self_maps.txt
}

function evalhex {
	echo -e "scale=0;obase=16;ibase=16;$(echo $@ | sed 'y/abcdef/ABCDEF/')" | bc -l | sed 'y/ABCDEF/abcdef/'
}

function parsesecs {
	section=$1
	vmbase=$2
	vmload=$3
	file=$4
	# only safe for sections >= index 10 (since the [ n] section is two tokens not one). .init == [10]
	secbounds=($(readelf -SW libreloc.so | awk '/[ 	]\.'${section}'[ 	]/ {print $4, $6}'))
	# do secbounds[0] - (vmload - vmbase)
	offset=$(evalhex "${secbounds[0]} + ${vmbase} - ${vmload}")
	extent=${secbounds[1]}
	echo -n "<tspan class=\"$(echo ${section} | sed 's/\./_/g') blm\"><!-- ${secbounds[0]} ${vmbase} ${vmload} ${offset} ${extent} ${file} -->"
	hexdump -vs 0x${offset} -n $((16#${extent})) -e '1/1 "%02x "' ${file}
	echo "</tspan>"
}

function getfile {
	find . -type f -name ${1}\* | cut -d/ -f2
}
# returns vm_load_address
x_vmaddr=$(getseg r-xp)
#echo "x_vmaddr: $x_vmaddr" >&2
#echo "x_file:   $(getfile ${x_vmaddr})" >&2
for section in init plt text fini rodata eh_frame ; do 
	parsesecs ${section} ${x_vmaddr} ${x_vmaddr} $(getfile ${x_vmaddr})
done

r_vmaddr=$(getseg r--p)
rwvmaddr=$(getseg rw-p)
#echo "r_vmaddr: ${r_vmaddr}" >&2
#echo "rwvmaddr: ${rwvmaddr}" >&2

rfile=$(getfile ${r_vmaddr})
rfilecc="${rfile}.concat"
cp -f ${rfile} ${rfilecc}
cat $(getfile ${rwvmaddr}) >> ${rfilecc}

for section in ctors dtors jcr dynamic got got.plt data bss; do 
	parsesecs ${section} ${x_vmaddr} ${r_vmaddr} ${rfilecc}
done

rm ${rfilecc}
