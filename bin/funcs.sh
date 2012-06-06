#!/bin/bash

function libbase {
	if [ ! -r "$1" ] ; then 
		echo "Cannot read file \"$1\"" >&2
	else
		grep 'r-xp.*'$1 proc_self_maps.txt | cut -d- -f 1
	fi
 }

function libfile {
	find . -type f -name "$(libbase $1)*" | cut -d/ -f 2
 }

function segfind {
	if [ $# -ne 2 ] ; then
		echo "Usage: segfind (ro|rw|x) file" >&2
	else 
		case $1 in 
		rw)
			token=rw-p;;
		x)
			token=r-xp;;
		ro)
			token=r--p;;
		esac
		grep $token.\*$2 proc_self_maps.txt | cut -d- -f 1 | xargs -i find . -type f -name "{}*" | cut -d/ -f2
	fi
 }

function secaddr {
	if [ $# -ne 2 ] ; then
		echo "Usage: secaddr section_without_leading_dot file" >&2
	else
		#  [ 4] .dynsym           DYNSYM          0000000000000240 000240 000120 18   A  5   2  8
		#       ^^^^^^^                           ^^^^^^^^^^^^^^^^ ^^^^^^ ^^^^^^
		#       \1                                \2               \3     \4
		readelf -SW $2 | sed -n 's/[ ]*\[[ 0-9]\{2\}\] \(\.'$1'\)[ ]\+[A-Z]\+[ ]\+\([0-9a-f]\+\) \([0-9a-f]\+\) \([0-9a-f]\+\).*/\1 \2 \3 \4/p'
	fi
 }

function vm4sec {
	# get the section's [name, addr, offset, len]
	values=($(secaddr $1 $2))
	# Add the 'Addr' value from 'readelf -SW' to the library's VM start-address given by function 
	# 'libbase'. Mask this value to a memory page by dividing and then multiplying by the page-size
	vmbase=$(libbase $2)
	vmaddr=$(evalhex "${values[1]} + $vmbase")
	segaddr=$(evalhex "($vmaddr/1000)*1000")
	# Do a FS search for a file matching the calculated prefix and remove the dot-slash prefix
	file=$(find . -type f -name "$segaddr*" | cut -d/ -f2)
	offset=$(grep ${segaddr}- proc_self_maps.txt | awk '{print $3}')
	offset=$(evalhex "$vmaddr - $segaddr - $offset")
	echo "$file $offset ${values[3]}"
 }

function hdsosec {
	values=($(secaddr $1 $2))
	hexdump -vCs 0x${values[2]} -n $(hex2dec ${values[3]}) $2
 }

function hdvmsec {
	# values are [filename, segoff, len]
	values=($(vm4sec $1 $2))
	hexdump -vC -s 0x${values[1]} -n $(hex2dec ${values[2]}) $2
 }

function evalhex {
	echo -e "scale=0;obase=16;ibase=16;$(echo $@ | sed 'y/abcdef/ABCDEF/')" | bc -l | sed 'y/ABCDEF/abcdef/'
 }

function hex2dec {
	echo $((16#$1))
 }

