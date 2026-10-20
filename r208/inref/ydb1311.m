;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; YDB#1311 : in UTF-8 mode, $QLENGTH() and $QSUBSCRIPT() must issue BADCHAR for a name holding a byte
; sequence that is not a valid UTF-8 character, unless VIEW "NOBADCHAR" is in effect, in which case each
; invalid byte is one character. In M mode every byte is one character.
;
; Each label below is run by qsubscript_badchar-ydb1311.csh. The source is kept ASCII, so every non-ASCII
; byte or character is built with $ZCHAR() or $CHAR().
;
ydb1311	;
	write "Run one label at a time. See qsubscript_badchar-ydb1311.csh",!
	quit
	;
badchar	; UTF-8 mode with VIEW "BADCHAR" : each name in badtab must issue BADCHAR naming its invalid bytes
	new i,line,name,nameexpr,seq
	view "BADCHAR"
	for i=1:1 set line=$text(badtab+i) quit:""=$piece(line,";",2)  do
	. set nameexpr=$piece(line,";",2),seq=$piece(line,";",3)
	. set @("name="_nameexpr)
	. do chkerr("$qlength("_nameexpr_")","$qlength(name)",$piece(line,";",4))
	. do chkerr("$qsubscript("_nameexpr_","_seq_")","$qsubscript(name,seq)",$piece(line,";",4))
	quit
	;
badtab	; name;subscript number;bytes BADCHAR names
	;"x("""_$zchar(128)_""")";1;128
	;"x("""_$zchar(255)_""")";1;255
	;"x("""_$zchar(195,40)_""")";1;195
	;"x("""_$zchar(224)_""")";1;224
	;"x("""_$zchar(237,160,128)_""")";1;237,160,128
	;"x(""a"",""b"_$zchar(128)_"c"")";1;128
	;"^x("""_$zchar(128)_""")";1;128
	;
	;
nobadchar ; UTF-8 mode with VIEW "NOBADCHAR" : each invalid byte in the names in valtab is one character
	view "NOBADCHAR"
	do chkall
	view "BADCHAR"
	quit
	;
mmode	; M mode : every byte of the names in valtab is one character
	do chkall
	quit
	;
chkall	; Check $QLENGTH() and $QSUBSCRIPT() of each name in valtab
	new i,line
	for i=1:1 set line=$text(valtab+i) quit:""=$piece(line,";",2)  do chkline(line)
	quit
	;
valtab	; name;subscript number;expected subscript;expected $QLENGTH()
	;"x("""_$zchar(128)_""")";1;$zchar(128);1
	;"x("""_$zchar(255)_""")";1;$zchar(255);1
	;"x("""_$zchar(195,40)_""")";1;$zchar(195,40);1
	;"x("""_$zchar(224)_""")";1;$zchar(224);1
	;"x("""_$zchar(237,160,128)_""")";1;$zchar(237,160,128);1
	;"x(""a"",""b"_$zchar(128)_"c"")";2;"b"_$zchar(128)_"c";2
	;"^x("""_$zchar(128)_""")";0;"^x";1
	;"^x("""_$zchar(128)_""")";1;$zchar(128);1
	;
	;
valid	; UTF-8 mode with VIEW "BADCHAR" : names whose subscripts hold valid 2, 3 and 4 byte characters
	new i,line
	view "BADCHAR"
	for i=1:1 set line=$text(validtab+i) quit:""=$piece(line,";",2)  do chkline(line)
	quit
	;
validtab ; name;subscript number;expected subscript;expected $QLENGTH()
	;"x("""_$char(233)_""","""_$char(8364)_""","""_$char(119070)_""")";1;$char(233);3
	;"x("""_$char(233)_""","""_$char(8364)_""","""_$char(119070)_""")";2;$char(8364);3
	;"x("""_$char(233)_""","""_$char(8364)_""","""_$char(119070)_""")";3;$char(119070);3
	;"x("""_$char(233)_"""_$c(1)_"""_$char(8364)_""",2)";1;$char(233,1,8364);2
	;"^x(""a"_$char(233)_""")";1;"a"_$char(233);1
	;
	;
zcoll	; UTF-8 mode with VIEW "BADCHAR" : $ZCOLLATE(name,0) and $VIEW("YGVN2GDS",name) accept the name the
	; reverse $ZCOLLATE(key,0,1) returns, which holds the subscript's bytes inside quotes as they are
	new bytes,i,key,line,raw,rev
	view "BADCHAR"
	for i=1:1 set line=$text(zcolltab+i) quit:""=$piece(line,";",2)  do
	. set bytes=$piece(line,";",2)
	. xecute "set raw=$zchar("_bytes_")"
	. set key=$zcollate("^x($ZCH("_bytes_"),2)",0),rev=$zcollate(key,0,1)
	. ; The bytes follow the opening quote, so $ZFIND() returns the position after "^x(" and the bytes
	. do chkval("$zfind($zcollate(key,0,1),$zchar("_bytes_")) for key=$zcollate(""^x($ZCH("_bytes_"),2)"",0)","$zfind(rev,raw)",5+$zlength(raw))
	. do chkval("$zcollate($zcollate(key,0,1),0)=key for key=$zcollate(""^x($ZCH("_bytes_"),2)"",0)","$zcollate(rev,0)=key",1)
	. do chkval("$view(""YGVN2GDS"",$zcollate(key,0,1))=key for key=$zcollate(""^x($ZCH("_bytes_"),2)"",0)","$view(""YGVN2GDS"",rev)=key",1)
	quit
	;
zcolltab ; bytes of the subscript
	;128
	;224
	;195,40
	;237,160,128
	;
	;
chkline(line) ; Check $QLENGTH() and $QSUBSCRIPT() of the name in one valtab or validtab line
	new name,nameexpr,seq,expect,explen
	set nameexpr=$piece(line,";",2),seq=$piece(line,";",3),explen=$piece(line,";",5)
	set @("name="_nameexpr),@("expect="_$piece(line,";",4))
	do chkval("$qlength("_nameexpr_")","$qlength(name)",explen)
	do chkval("$qsubscript("_nameexpr_","_seq_")","$qsubscript(name,seq)",expect)
	; The $LENGTH() of the subscript must count characters by the same rule as for the expected value
	do chkval("$length($qsubscript("_nameexpr_","_seq_"))","$length($qsubscript(name,seq))",$length(expect))
	quit
	;
chkval(desc,expr,expect) ; Check that evaluating expr returns expect without an error
	new result,zstatus
	do eval(expr,.result,.zstatus)
	if ""'=zstatus write "WRONG : ",desc," issued ",$piece(zstatus,",",3,99),", expected ",$$fmt(expect),! quit
	if result'=expect write "WRONG : ",desc," returned ",$$fmt(result),", expected ",$$fmt(expect),! quit
	write "PASS : ",desc," returned ",$$fmt(result),!
	quit
	;
chkerr(desc,expr,bytes) ; Check that evaluating expr issues BADCHAR naming $ZCHAR(bytes)
	new expect,result,zstatus
	set expect="-E-BADCHAR, $ZCHAR("_bytes_") is not a valid character in the UTF-8 encoding form"
	do eval(expr,.result,.zstatus)
	if ""=zstatus write "WRONG : ",desc," returned ",$$fmt(result),", expected BADCHAR for $ZCHAR(",bytes,")",! quit
	if zstatus'[expect write "WRONG : ",desc," issued ",$piece(zstatus,",",3,99),", expected BADCHAR for $ZCHAR(",bytes,")",! quit
	write "PASS : ",desc," issued ",$piece(zstatus,",",3,99),!
	quit
	;
eval(expr,result,zstatus) ; Evaluate expr into result, or set zstatus to $ZSTATUS if it issues an error
	new $etrap
	set result="",zstatus=""
	set $etrap="set zstatus=$zstatus,$ecode="""" quit"
	xecute "set result="_expr
	quit
	;
fmt(x)	; x in ZWRITE form, with each byte outside 32-126 written as $ZCH(), so the output is ASCII in either mode
	new b,i,inq,inz,out
	if x=+x quit x
	set out="",inq=0,inz=0
	for i=1:1:$zlength(x) set b=$zascii(x,i) do
	. if (31<b)&(127>b) do  quit
	. . if inz set out=out_")",inz=0
	. . if 'inq set out=out_$select(""=out:"",1:"_")_"""",inq=1
	. . set out=out_$select(34=b:"""""",1:$char(b))
	. if inq set out=out_"""",inq=0
	. if inz set out=out_","_b quit
	. set out=out_$select(""=out:"",1:"_")_"$ZCH("_b,inz=1
	if inq set out=out_""""
	if inz set out=out_")"
	if ""=out set out=""""""
	quit out
