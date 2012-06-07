function getSection(libaddr) {
	off=libaddr-baseoff;
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

BEGIN {
	baseoff=strtonum(hexbase);
	split(varargs, valarrays, ";");
	split(valarrays[1], r_names, ",");
	split(valarrays[2], r_offsets, ",");
	split(valarrays[3], r_lengths, ",");
	len=length(r_names);
	for (i=1;i<len;i++) {
		t_offsets[r_names[i]]=strtonum(r_offsets[i]);
		t_lengths[r_names[i]]=strtonum(r_lengths[i]);
	}
	
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

	print " .none {fill:#000}";
	print " .init { fill:#600 }";
	print " .plt { fill:#060 }";
	print " .text { fill:#006 }";
	print " .fini { fill:#C09 }";
	print " .rodata { fill:#099 }";
	print " .eh_frame { fill:#999 }";
	print " .ctors { fill:#909 }";
	print " .dtors { fill:#CC0 }";
	print " .jcr { fill:#C0C }";
	print " .got { fill:#F00 }";
	print " .got.plt { fill:#00F }";
	print " .data { fill:#0F) }";
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

/^[0-9]/ {
	lineoff=strtonum("0x"$1);
	realoff=baseoff+lineoff;
	ascstart=index($0, "|");
	ascend=length($0);
	addrend=length($1);
	bytestr=substr($0, addrend+1, ascstart-addrend-1);
	charstr=substr($0, ascstart+1, ascend-ascstart-1);
	gsub(/&/, "\&amp;", charstr);
	split(bytestr, bytearr, " ");
	bytelen=length(bytearr);

	printf "<tspan x=\"10\" dy=\"16\">%x</tspan>", realoff;
	if (NF == 1) {
		print "";
		next;
	}
	for (i = 1 ; i < bytelen ; i++) {
		if (i < 9) {
			byteoff=realoff+i-1;
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
			if (i == 8 || i == bytelen -1) printf "</tspan>";
		}
		else {
			if (i == 9) {
				s_sec=getSection(byteoff);
				printf "<tspan dx=\"30\" class=\"%s\">", s_sec;
			}
			printf "%02x", strtonum("0x" bytearr[i]);
			if (i < bytelen-1) {
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
	printf "<tspan x=\"530\">|<tspan class=\"%s\">", "dl";
	printf "%s", charstr;
	printf "</tspan>|</tspan>";
#	printf "str: %s, pos: %d, len: %d, count: %d", bytestr, addrend+1, 
	print "";
}
