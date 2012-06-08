#!/usr/bin/awk 

$1 ~ /\[[ 0-9]*\]/ {
	value=sprintf("%s%d,", value, strtonum("0x" $4));
	name=sprintf("%s%s,", name, substr($2, 2, length($2)-1));
	len=sprintf("%s%d,", len, strtonum("0x" $6));
}

END {
	printf "%s;%s;%s\n", name, value, len;
}
