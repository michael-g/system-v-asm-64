#!/usr/bin/awk 

BEGIN {
	split(filenames, files, ",");
	idx=1;
	for (i = 1 ; i <= length(files) ; i++) {
		readFile(files[i]);
	}
	for (i = idx ; i >= 1 ; i--) {
		print lines[i];
	}
}

function readFile(fileName) {
	split(fileName, fnTokens, "_");
	vmstart=strtonum("0x" fnTokens[1]);
	vmend=strtonum("0x" fnTokens[2]);
	vmlen=vmend-vnstart;
	cmd="hexdump -vC " fileName;
	while ( ( cmd | getline result ) > 0 ) {
		split(result, tokens, " ");
		if (length(tokens) > 1) {
			lineoff=strtonum("0x" tokens[1]) + vmstart;
			offlen=length(tokens[1])+1;
			lines[idx++] = sprintf("%x", lineoff) " " substr(result, offlen, length(result)-offlen+1);
		}
	}
}
