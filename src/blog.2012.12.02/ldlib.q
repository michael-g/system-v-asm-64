/
 (c) Michael Guyver, 2012, all rights reserved. Permission to use, copy, modify and distribute the 
 software is hereby granted for educational use which is non-commercial in nature, provided that 
 this copyright  notice and following two paragraphs are included in all copies, modifications and 
 distributions.

 THIS SOFTWARE AND DOCUMENTATION IS PROVIDED "AS IS," AND NO REPRESENTATIONS OR WARRANTIES ARE 
 MADE, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO, WARRANTIES OF MERCHANTABILITY OR 
 FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE SOFTWARE OR DOCUMENTATION WILL NOT 
 INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.

 COPYRIGHT HOLDERS WILL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL OR CONSEQUENTIAL DAMAGES 
 ARISING OUT OF ANY USE OF THE SOFTWARE OR DOCUMENTATION.
\

/ load the shared library 'libpmc.so' and assign the 5-arg function 'runtest' to .pmc.runtestdl
.mg.or:`libkdbavxor 2:(`mgBitwiseOr;2);
v:`byte$20000000#til 0xFF;
.mg.or[v;0x04]
