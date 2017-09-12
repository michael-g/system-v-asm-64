unixToZp:{
  12h$((x * 1000000000)+y*1000)+ 7h$1970.01.01D
 }
uncap:{
  //x:0 8 12 16 22 28 30 42 46 50 52 54 82 cut x
 ;tp:unixToZp[0x0 sv x[reverse til 4];0x0 sv x[4+reverse til 4]]   / the timestamp
 ;sz:0x0 sv reverse x 8+til 4                                      / _captured_ packet length
 ;b:(tp;sz)
 ;b,:b[1]~0x0 sv reverse x 12+til 4                                / whether the original packet length matches the captured length
 ;b,:`$":" sv string x 22+til 6                                    / src MAC: dest comes first but this is reversed
 ;b,:`$":" sv string x 16+til 6                                    / dest MAC
 ;b,:$[0x800~x 28 29;`IP;`]                                        / Eth.protocol: IP packet, or something else
 ;ipsz:4*0b sv 0000b,4_0b vs x 30                                  / IP header length in bytes 
 ;b,:0x0 sv x 32+til 2                                             / total IP packet length
 ;b,:?[0x06~x 39;`TCP;`]                                           / IP.protocol; TCP packet or something else
 ;b,:`$"." sv string 6h$x 42+til 4                                 / src IP
 ;b,:`$"." sv string 6h$x 46+til 4                                 / dst IP
 ;tcp:30+ipsz                                                      / TCP header offset
 ;b,:5h$0x0 sv 0x0000,x tcp+til 2                                  / src port
 ;b,:5h$0x0 sv 0x0000,x tcp+2+til 2                                / src port
 ;tcpsz:4*0b sv 0000b,-4_0b vs x tcp+12                            / TCP header length
 ;b,:(count x) - (tcp+tcpsz)                                       / data.length
 ;b,:enlist (tcp+tcpsz)_x                                          / the data
 ;b
 } 
tcphdr:{
  sp:x 9
 ;dp:x 10 
 ;seq:0x0 sv 0x00000000,x[11] til 4
 ;ack:0x0 sv 0x00000000,x[11] 4+til 4
 ;len:4h*0b sv 0000b,-4_0b vs first x[11] 8
 ;win:0x0 sv x[11]10 11
 / {x[0]:0x0 sv 0x00000000,x 0;x[1]:0x0 sv 0x00000000,x 1;x[2]:4h*0b sv 0000b,-4_0b vs first x 2;x[4]:0x0 sv x 4;x[10]:(0x0 sv x[10;0 1 2 3];0x0 sv x[10;4 5 6 7]);x} each 0 4 8 9 10 12 14 16 18 19 20 cut/: t[;11]
 ;`src`dst`seq`ack`len`win!(sp;dp;seq;ack;len;win)
 }
idxcap:{
  -2_{if[y > count x;:y]; 16+y+0x0 sv x y + 11 10 9 8}[x]\[0]
 }
splitcap:{
  pkt:24_x
 ;idx:idxcap pkt
 ;idx cut pkt
 }
readcap:{
  flip`row`sip`sp`dip`dp`dsz`data!(enlist til count x),flip x:(uncap each splitcap x)[;8 10 9 11 12 13]
 }




tls.ch.idxExtns:{                                                  / return Extension-boundary indices which can be used as the RH argument to 'cut'
  -1_{if[y=count x;:y];y+4+0x0 sv x y+2 3}[x]\[y]
 }
tls.ch.cutExtns:{                                                  / given the Extension data (payload), cut the byte vector into discrete extension (id;len;data) byte vector values
  0 2 4 cut/: tls.ch.idxExtns[x;y] cut x
 }
tls.cph.load:{                                                     / from https://www.thesprawl.org/research/tls-and-ssl-cipher-suites/ 
  update CipherID:{value "0x",4_x} each CipherID from ("*SSSSIS";enlist ",") 0: `:ciphers.csv
 }
tls.xtn.load:{                                                     / from https://www.iana.org/assignments/tls-extensiontype-values/tls-extensiontype-values.xhtml
  ("ISS";enlist",") 0:`:extensions.csv
 }
tls.ch.parse:{
  len:0x0 sv 0x00,x 6+til 3                                        / client-hello encodes length as 24 bits/3 bytes 
 ;pcl:x 9 10                                                       / selected protocol is written as two bytes
 ;rnd:x 11+til 32                                                  / 32 bytes of random data
 ;idz:x 43                                                         / SessionID length is written as a single byte
 ;sid:x 44+til idz                                                 / SessionID data
 ;off:44+idz                                                       / numbers now variable, so keep an 'offset' value
 ;chz:0x0 sv x off+0 1                                             / cipher data length is written as a uint16
 ;cph:2 cut x (off+:2)+til chz                                     / ciphers are written as 2-byte values
 ;cph:exec Name from tls.cph.load[] where CipherID in cph          / convert cipher ID values to names
 ;zsz:x (off+:chz)                                                 / compression algorithm's lenght is a single byte
 ;zlg:x (off+:1)+til zsz                                           / read compression algos data
 ;exz:0x0 sv x (off+:zsz)+0 1                                      / extension data is written as a uint16
 ;exn:(tls.ch.cutExtns[x;off+:2])[;0 2]
 ;exn:(exec name from tls.xtn.load[] where ID in 6h$0x0 sv/: exn[;0])!exn[;1]
 ;ch:`Len`Proto`Rnd`IdLen`Id`CipherLen`Ciphers`ZLen`ZAlgos`ExtnLen`Extns!(len;pcl;rnd;idz;sid;chz;cph;zsz;zlg;exz;exn)
 }
tls.hs.parse:{
  hdr:`MsgTyp`Proto`MsgLen`HsTyp!(`Handshake;x 1 2;0x0 sv x 3 4;`) / protocol is bytes[1 2], message length bytes[3 4]
 ;$[0x01~typ:x 5                                                   / handshake type is encoded in byte[5]; client-hello is value 0x01
   ;[hdr[`HsTyp]:`ClientHello;`Header`Record!(hdr;tls.ch.parse x)] / delegate to client-hello parser
   ;'"Cannot handle handshake type ",string typ
   ]
 }
tls.msg.parse:{
  if[not 0x03~x 1;'"Cannot parse non-TLS messages yet"]
 ;if[(5+0x0 sv x 3 4)>count x;'"Insufficient data: total message length is ",string 5+0x0 sv x 3 4]
 ;$[0x16~typ:first x                                               / 22=handshake
   ;tls.hs.parse x
   ;'"Cannot handle message type ",string typ
   ]
 }
