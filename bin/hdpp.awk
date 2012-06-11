#!/usr/bin/awk 

BEGIN {
	imgbase=strtonum(imgbase);
	split(varargs, valarrays, ";");
	split(valarrays[1], r_names, ",");
	split(valarrays[2], r_offsets, ",");
	split(valarrays[3], r_lengths, ",");
	len=length(r_names);
	for (i=1;i<=len;i++) {
		t_offsets[r_names[i]]=strtonum(r_offsets[i]);
		t_lengths[r_names[i]]=strtonum(r_lengths[i]);
	}
	print valarrays[1] > "/dev/stderr"
	print valarrays[2] > "/dev/stderr"
	print valarrays[3] > "/dev/stderr"
	printf "%x\n", baseoff > "/dev/stderr"
	print "<svg xmlns:dc=\"http://purl.org/dc/elements/1.1/\"";
	print " xmlns:cc=\"http://creativecommons.org/ns#\"";
	print " xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"";
	print " xmlns:svg=\"http://www.w3.org/2000/svg\"";
	print " xmlns=\"http://www.w3.org/2000/svg\"";
	print " xmlns:xlink=\"http://www.w3.org/1999/xlink\"";
	print " width=\"790px\"";
	print " height=\"2024px\"";
	print " version=\"1.1\"";
	print " >";
	print " <style type=\"text/css\"><![CDATA[";

	print " .none {fill:#d1d1d1 }"; # light-grey
	print " .note.gnu.build-id {fill:#0a1a1a }"; # very dark blue-grey
	print " .hash {fill:#1f4c4c }"; # dark blue-grey
	print " .gnu.hash {fill:#296666 }"; # blue-grey
	print " .dynstr {fill:#334c00 }"; # dark-green
	print " .dynsym {fill:#527a00 }"; # lighter-green
	print " .gnu.version {fill:#727272 }"; # some kind of grey
	print " .gnu.version_r {fill:#b5b5b5 }"; # some kind of grey
	print " .rela.dyn {fill:#855C33 }"; # light-brown
	print " .rela.plt {fill:#754719 }"; # mid-brown
	print " .init {fill:#990033 }";# purple
	print " .plt {fill:#ff6600 }"; # orange
	print " .text {fill:#cc0000 }"; # red
	print " .fini {fill:#8f0000 }"; # dark-red
	print " .eh_frame {fill:#a6a6a6 }"; # light-grey
	print " .ctors {fill:#ff4d4d }"; # pale-red
	print " .dtors {fill:#ff8533 }"; # pale-orange
	print " .jcr {fill:#7a7a7a }"; # dark-grey
	print " .dynamic {fill:#D8D8A3 }"; #B2B247 }"; #e6b800 }"; # dark-yellow
	print " .rodata {fill:#0066ff }"; # mid-blue
	print " .got {fill:#003d99 }"; # darker-blue
	print " .got.plt {fill:#668bc2 }"; # lighter-blue
	print " .data {fill:#009999 }"; # teal/cyan?
	print " .bss {fill:#338533 }"; # light-green
	print " .comment {fill:#cccccc }";
	print " .shstrtab {fill:#b5b5b5 }"; # some kind of grey
	print " .symtab {fill:#727272 }"; # some kind of grey
	print " .strtab {fill:#a3a3a3 }"; # some kind of grey

	print " .code {text-anchor:left-top;font-size:13px;font-family:Courier;font-weight:bold;fill:#000}";
	print " .norm {font-family:Arial;font-weight:normal}";
	print " .line {fill:none;stroke:#000000;stroke-width:1px}";
	print " ]]></style>";
	print " <defs>";
	print "  <polygon id=\"arrow\" points=\"0,4 8,0 8,8\" style=\"fill:#000000\"/>";
	print " </defs>";
	print " <text x=\"10\" y=\"80\" class=\"code\" >";
 }

END {
	print " </text>";
	print "</svg>";
 }

function getSection(pos) {
	off=pos-imgbase;
	j=length(r_names);
	for ( ; j > 0 ; j--) {
		addr=t_offsets[r_names[j]];
		if (addr == 0) {
			continue;
		}
		if (off >= addr && off < (addr + t_lengths[r_names[j]])) {
			return r_names[j];
		}
	}
	return "none";
 }

/^[0-9]/ {
	lineoff=strtonum("0x"$1);
	ascstart=index($0, "|");
	ascend=length($0);
	addrend=length($1);
	bytestr=substr($0, addrend+1, ascstart-addrend-1);
	charstr=substr($0, ascstart+1, ascend-ascstart-1);
	gsub(/&/, "\&amp;", charstr);
	split(bytestr, bytearr, " ");
	bytelen=length(bytearr);

	printf "<tspan x=\"10\" dy=\"16\">%x</tspan>", lineoff;
	if (NF == 1) {
		print "";
		next;
	}
	for (i = 1 ; i <= bytelen ; i++) {
		byteoff=lineoff+i-1;
		if (i < 9) {
			if (i == 1) {
				s_sec=getSection(byteoff);
				printf "<tspan dx=\"30\" class=\"%s\">", s_sec;
			}
			else printf " ";
			t_sec=getSection(byteoff);
			if (t_sec != s_sec) {
				s_sec=t_sec;
				printf "</tspan><tspan class=\"%s\">", s_sec;
			}
			printf "%02x", strtonum("0x" bytearr[i]);
			if (i == 8 || i == bytelen) printf "</tspan>";
		}
		else {
			if (i == 9) {
				s_sec=getSection(byteoff);
				printf "<tspan dx=\"30\" class=\"%s\">", s_sec;
			}
			printf "%02x", strtonum("0x" bytearr[i]);
			if (i < bytelen) {
				printf " ";
				t_sec=getSection(byteoff);
				if (t_sec != s_sec) {
					s_sec=t_sec;
					printf "</tspan><tspan class=\"%s\">", s_sec;
				}
			}
			else printf "</tspan>";
		}
	}
	printf "<tspan x=\"560\">|<tspan class=\"%s\">", "none";
	printf "%s", charstr;
	printf "</tspan>|</tspan>";
#	printf "str: %s, pos: %d, len: %d, count: %d", bytestr, addrend+1, 
	print "";
}
