;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2010, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
testpiecesunicode
	do ^echoline
	; Pre-load data to show changes to $ztupdate
	write "Pre-load some data",!
	do bytebybyte
	do bytebychar
	do charbychar
	do charbybyte

	; load the trigger file before doing the test
	do text^dollarztrigger("tfile^testpiecesunicode","testpiecesunicode.trg")
	do file^dollarztrigger("testpiecesunicode.trg",1)

	; Now run the tests showing changes to $ztupdate
	do ^echoline
	write "Run the pieces/delim tests",!
	do change
	do ^echoline
	quit

	; change globals to fire triggers and show changes to $ztupdate
change
	kill index
	; byte delimiter on byte boundaries - zchar+zdelim
	; use $zpiece so that we get a real byte stream
	do ^echoline
	write !,"byte by byte",!
	set str=^delim("zchar",$increment(index))
	set $zpiece(str,$zchar(124),1)=$zchar(224,171,166+0)
	set ^delim("zchar",index)=str
	for i=3:1:5 set $zpiece(str,$zchar(124),i+1)=$zchar(224,171,166+i)
	set ^delim("zchar",index)=str

	set str=^delim("zchar",$increment(index))
	for i=2:1:3 set $zpiece(str,$char(254),i+1)=$zchar(224,171,166+i)
	set ^delim("zchar",index)=str
	if $data(^fired) zwrite ^fired kill ^fired

	; byte delimiter on unicode character boundaries - zchar+delim
	do ^echoline
	write !,"byte by char",!
	set str=^delim("zchar",$increment(index))
	for i=1:1:3 set $zpiece(str,$char(254,254),i+1)=$zchar(224,171,166+i)
	set ^delim("zchar",index)=str
	for i=4:1:6 set $zpiece(str,$char(254,254),i+1)=$zchar(224,171,166+i)
	set ^delim("zchar",index)=str
	if $data(^fired) zwrite ^fired kill ^fired

	; unicode delimiter on unicode character boundaries - char+delim
	do ^echoline
	write !,"char by char",!
	set str="૦|૧|૨|૩|૪|૫|૬|૭|૮|૯"
	set ^delim("char",$increment(index))=str
	set str="०|१|૨|૩|४|૫|६|૭|૮|૯"
	set ^delim("char",index)=str
	set str="०|१|२|३|४|५|६|७|८|९"
	set ^delim("char",index)=str

	set str="A।B।C।D।F।G।H।I।J"
	set ^delim("unichar",$increment(index))=str
	set str="A।B।C।D।F।G।H।I।J"
	set ^delim("unichar",index)=str

	set str="a।b।c।d।।।४।।५।।६।।७।।८"
	set ^delim("multichar",$increment(index))=str
	set str="a।b।cccp।d।।।4।।५।।६।।७।10।८"
	set ^delim("multichar",index)=str
	if $data(^fired) zwrite ^fired kill ^fired

	; unicode delimiter on byte boundaries - char+zdelim
	; mangle gujarati numbers into hindi numbers
	do ^echoline
	write !,"char by byte",!
	set str="૦|૧|૨|૩|૪|૫|૬|૭|૮|૯"
	set ^delim("unichar",$increment(index))=str
	write str,!,^delim("unichar",index),!
	if $data(^fired) zwrite ^fired kill ^fired
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; byte delimiter on byte boundaries - zchar+zdelim
	; use $zpiece so that we get a real byte stream
bytebybyte
	do ^echoline
	write !,"byte by byte",!
	kill str
	for i=0:1:4 set $zpiece(str,$zchar(124),i+1)=$zchar(224,165,166+i)
	set ^delim("zchar",$increment(index))=str
	write index,$char(9),str,$char(9),$zlength(str),!
	if $data(^fired) zwrite ^fired kill ^fired

	kill str
	for i=0:1:4 set $zpiece(str,$char(254),i+1)=$zchar(224,165,166+i)
	set ^delim("zchar",$increment(index))=str
	write index,$char(9),str,$char(9),$zlength(str),!
	if $data(^fired) zwrite ^fired kill ^fired
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; byte delimiter on unicode character boundaries - zchar+delim
bytebychar
	do ^echoline
	write !,"byte by char",!
	kill str
	for i=0:1:4 set $piece(str,$char(254,254),i+1)=$zchar(224,165,166+i)
	set ^delim("zchar",$increment(index))=str
	write index,$char(9),str,$zchar(9),$zlength(str),!
	if $data(^fired) zwrite ^fired kill ^fired
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; unicode delimiter on unicode character boundaries - char+delim
charbychar
	do ^echoline
	write !,"char by char",!
	set str="૦|૧|૨|૩|૪|૫|૬|૭|૮|૯"
	set ^delim("char",$increment(index))=str
	write index,$char(9),str,$char(9),$zlength(str),!
	if $data(^fired) zwrite ^fired kill ^fired

	kill str
	for i=5:1:9 set $piece(str,$char(2404),i)=$char(65+i)
	set ^delim("unichar",$increment(index))=str
	write index,$char(9),str,$char(9),$zlength(str),!
	if $data(^fired) zwrite ^fired kill ^fired

	kill str
	for i=4:1:8 set $piece(str,$char(2404,2404),i)=$char(2406+i)
	set ^delim("multiunichar",$increment(index))=str
	write index,$char(9),str,$char(9),$zlength(str),!
	if $data(^fired) zwrite ^fired kill ^fired
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; unicode delimiter on byte boundaries - char+zdelim
charbybyte
	do ^echoline
	write !,"char by byte",!
	set str="0|૧|૨|3|૪|5|૬|૭|૮|9"
	set ^delim("unichar",$increment(index))=str
	write index,$char(9),str,$char(9),$zlength(str),!
	if $data(^fired) zwrite ^fired kill ^fired
	quit

squelch
	kill ^delim,^fired
	quit

	;--------------------------------------------------------------
rtn
	set ref=$reference
	zshow "s":stack set ZTNAme=stack("S",2)
	set x=$increment(^fired(ZTNAme))
	set $piece(^fired(ZTNAme,x),".",$i(i))=ref
	set $piece(^fired(ZTNAme,x),".",$i(i))=$ZTDElim
	set $piece(^fired(ZTNAme,x),".",$i(i))=$ZTUPdate
	quit

	; The following M routine is used for testing zdelim+zchar and
	; piece matching. A little information before delving into
	; insanity.  The gujarati characters are of the byte format
	; 224,171,XXX The hindi characters are of the byte format
	; 224,165,XXX In both XXX are similar characters in both
	; scripts. We are going to take advantage of the fact that XXX
	; are equal for all numeric characters.  The delimiter for the
	; test is $zchar(124,224) which are the pipe char, "|", and the
	; highest byte of the hindi and gujarati character encoding.
	; The test uses a string of gujarati numeric chars from 0 to 9
	; delimited by $char(124), aka "|" and converts them to the
	; hindi versions of those same characters.  zchar is used in
	; the trigger specification (its the last one in the in-line
	; trigger file) to target byte 124 and the highest byte, 224,
	; that is common between gujarati and hindi utf8 characters.
	; This yields a two bytes when broken up with $zpiece.  If the
	; first of the two bytes is 171, it's from the gujarati
	; character group, and is converted to 161 leaving the second
	; byte untouched. This effectively converts the gujarati number
	; to a hindi number.
	;
	; What might be a bug in the $zpiece implementation forced the
	; use of VIEW "nobadchar".  I could not SET the byte delimited
	; piece to the two desired bytes.  I tried a similar experiment
	; outside triggers and that failed as well.
remap(ascii,byte)
	set done=0,str=$ztvalue
	view "NOBADCHAR"
	for i=1:1:$length($ZTUPdate,",")  do
	.	set next=$piece($ZTUPdate,",",i)
	.	set bytes=$zpiece(str,$zchar(ascii,byte),next)
	.	if $zascii(bytes,1)=171 set bytes=$zchar(165,$zascii(bytes,2))
	.	set $zpiece(str,$zchar(ascii,byte),next)=bytes
	view "BADCHAR"
	set $ztvalue=str
	quit

tfile
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; byte delimiter on byte boundaries - zchar+zdelim
	;; use an ASCII character to delimit unicode characters WITH ZDELIM
	;+^delim("char";"zchar";"zdelim",lvn=:) -command=S -xecute="do rtn^testpiecesunicode" -zdelim="|" -name=BbyB0zd
	;+^delim("char";"zchar";"zdelim",lvn=:) -command=S -xecute="do rtn^testpiecesunicode" -zdelim=$char(254) -name=BbyB0zd0inv
	;+^delim("char";"zchar";"zdelim",lvn=:) -command=S -xecute="do rtn^testpiecesunicode" -zdelim=$char(254,254) -name=BbyB0zd0inv2
	;
	;; add pieces
	;+^delim("char";"zchar";"zdelim",lvn=:) -command=S -xecute="do rtn^testpiecesunicode" -zdelim="|" -piece=1:2 -name=BbyB0zd0zp
	;+^delim("char";"zchar";"zdelim",lvn=:) -command=S -xecute="do rtn^testpiecesunicode" -zdelim=$char(254) -piece=5:10 -name=BbyB0zd0zp0inv
	;+^delim("char";"zchar";"zdelim",lvn=:) -command=S -xecute="do rtn^testpiecesunicode" -zdelim=$char(254) -piece=1000  -name=BbyB0zd0zp0nofire
	;+^delim("char";"zchar";"zdelim",lvn=:) -command=S -xecute="do rtn^testpiecesunicode" -zdelim=$char(254,254) -piece=5:10 -name=BbyB0zd0zp0inv2
	;+^delim("char";"zchar";"zdelim",lvn=:) -command=S -xecute="do rtn^testpiecesunicode" -zdelim=$char(254,254) -piece=1000 -name=BbyB0zd0zp0nofire2
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; byte delimiter on unicode character boundaries - zchar+delim
	;; use an ASCII character to delimit unicode characters
	;+^delim("char";"zchar";"zdelim",lvn=:) -command=S -xecute="do rtn^testpiecesunicode" -delim="|" -piece=4 -name=BbyC0d0p
	;+^delim("char";"zchar";"zdelim",lvn=:) -command=S -xecute="do rtn^testpiecesunicode" -delim=$char(254) -piece=4 -name=BbyC0d0p0inv
	;+^delim("char";"zchar";"zdelim",lvn=:) -command=S -xecute="do rtn^testpiecesunicode" -delim=$char(254,254) -piece=4 -name=BbyC0d0p0inv2
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; unicode delimiter on unicode character boundars - zchar+delim
	;; use unicode characters to delimit unicode strings
	;+^delim("unichar",lvn=:) -command=S -xecute="do rtn^testpiecesunicode" -delim=$char(2404) -name=CbyC0d
	;+^delim("multiunichar",lvn=:) -command=S -xecute="do rtn^testpiecesunicode" -delim=$char(2404,2404) -name=CbyC0d02
	;
	;; add pieces
	;+^delim("unichar",lvn=:) -command=S -xecute="do rtn^testpiecesunicode" -delim=$char(2404) -piece=1:2;4 -name=CbyC0d0p
	;+^delim("multiunichar",lvn=:) -command=S -xecute="do rtn^testpiecesunicode" -delim=$char(2404,2404) -piece=1:2;4 -name=CbyC0d0p02
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; unicode character(s) delimiter on byte boundaries - [z]char+zdelim
	;; use a unicode character to delimit byte strings
	;+^delim("unichar",lvn=:) -command=S -xecute="do d^mrtn(""$zchar(124,224)"") do remap^testpiecesunicode(124,224)" -zdelim=$zchar(124,224) -name=CbyB0zd
