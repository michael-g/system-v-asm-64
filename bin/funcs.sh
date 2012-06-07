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
	# Find the base VM address for the library's image
	vmbase=$(libbase $2)
	# Add the 'Address' value to the base address
	vmaddr=$(evalhex "${values[1]} + $vmbase")
	# Mask the value to the page-size to get an image-base address (this is very simplistic)
	segaddr=$(evalhex "($vmaddr/1000)*1000")
	# Do a FS search for a file matching the calculated file-prefix and remove the leading dot-slash
	file=$(find . -type f -name "$segaddr*" | cut -d/ -f2)
	# Calculate the offset into the segment at which we should find our data
	offset=$(evalhex "$vmaddr - $segaddr")
	# Return "file_name hex_offset hex_length"
	echo "$file $offset ${values[3]}"
 }

function hdsosec {
	values=($(secaddr $1 $2))
	echo "hexdump -vCs 0x${values[2]} -n $(hex2dec ${values[3]}) $2"
	hexdump -vCs 0x${values[2]} -n $(hex2dec ${values[3]}) $2
 }

function hdvmsec {
	# values are [filename, segoff, len]
	values=($(vm4sec $1 $2))
	echo "hexdump -vC -s 0x${values[1]} -n $(hex2dec ${values[2]}) ${values[0]}"
	hexdump -vC -s 0x${values[1]} -n $(hex2dec ${values[2]}) ${values[0]}
 }

function evalhex {
	echo -e "scale=0;obase=16;ibase=16;$(echo $@ | sed 'y/abcdef/ABCDEF/')" | bc -l | sed 'y/ABCDEF/abcdef/'
 }

function hex2dec {
	echo $((16#$1))
 }

function hdle {
	awk '{ print $9 $8 $7 $6 $5 $4 $3 $2 }'
 }

function qwle {
	hexdump -ve '8/1 "%02x " "\n"' -s $1 -n 8 libreloc.so | awk '{print $8 $7 $6 $5 $4 $3 $2 $1}'
 }

function dwle {
	hexdump -ve '4/1 "%02x " "\n"' -s $1 -n 4 libreloc.so | awk '{print $4 $3 $2 $1}'
 }

function gensvg {
	if [ $# -ne 5 ] ; then
		echo "Usage: gensvg <offset> <len> \$(segfind <tkn> <lib>) <outname>" >&2 
	else 
		offset=$1
		len=$2
		file=$(segfind $3 $4)
		hexbase=0x$(echo $file | cut -f_ -d1)
		varargs=$(readelf -SW $4 | awk -f resw.awk)
		outfile=$5
		hexdump -vC -s $offset -n $len $file | sed -n '1!G;h;$p' | awk -f hdpp.awk -v hexbase=$hexbase -v varargs=$varargs > $outfile
	fi
 }
