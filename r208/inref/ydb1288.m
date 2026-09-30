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
; YDB#1288 : a $C() or $ZCH() argument in a ZWRITE format string, or a trigger -pieces= value, that does not fit in
; a 32-bit signed integer must be rejected, not wrapped around modulo 2**32, and must not fail an assert.
;
; Each label below is run by char_code_overflow-ydb1288.csh.
;
ydb1288	;
	write "Run one label at a time. See char_code_overflow-ydb1288.csh",!
	quit
	;
zwr	; $ZWRITE(str,1) of a $C() or $ZCH() whose argument is too large for an int, and controls
	new i,line,y
	for i=1:1 set line=$text(zwrtab+i) quit:""=$piece(line,";",2)  do
	. set y=$piece(line,";",2)
	. do chk("$zwrite("_$zwrite(y)_",1)",$zwrite(y,1),$$expect($piece(line,";",3)))
	quit
	;
zwrtab	; ZWRITE format string;expected result, as a list of $C() codes
	;$C(4294967361);
	;$ZCH(4294967361);
	;$C(8589934657);
	;$C(4294967296065);
	;$C(4294967306);
	;$C(2147483648);
	;$C(2147483713);
	;$C(18446744073709551681);
	;$C(65,4294967361);
	;"X"_$C(4294967361);
	;$C(2147483647);
	;$C(65);65
	;$C(0065);65
	;$ZCH(255);255
	;$C(1,2,3);1,2,3
	;
	;
zwrutf8	; $ZWRITE(str,1) in UTF-8 mode, where $C() takes code points above 255
	do chk("$zwrite(""$C(4294968530)"",1)",$zwrite("$C(4294968530)",1),"")
	do chk("$zwrite(""$C(4296081405)"",1)",$zwrite("$C(4296081405)",1),"")
	do chk("$zwrite(""$C(1234)"",1)",$zwrite("$C(1234)",1),$char(1234))
	do chk("$zwrite(""$C(1114109)"",1)",$zwrite("$C(1114109)",1),$char(1114109))
	quit
	;
random	; $ZWRITE("$C(n)",1) for 1000 values of n = k*2**32+c, where c is a valid code and k is 1 to 2**20
	new i,k,c,n,r,wrong
	set wrong=0
	for i=1:1:1000 do  quit:10<wrong
	. set k=1+$random(1048576),c=$random(256),n=k*4294967296+c
	. set r=$zwrite("$C("_n_")",1)
	. quit:""=r
	. set wrong=wrong+1
	. write "WRONG : $zwrite(""$C(",n,")"",1) returned ",$zwrite(r),", expected """"",!
	if wrong write "WRONG : ",wrong," value(s) accepted",!
	else  write "PASS : $zwrite(""$C(n)"",1) returned """" for 1000 values of n = k*2**32+c, with c from 0 to 255",!
	quit
	;
qsub	; $QSUBSCRIPT() of a name whose subscript is a $C() with an argument too large for an int
	do chk("$qsubscript(""x($C(4294967361))"",1)",$qsubscript("x($C(4294967361))",1),"")
	do chk("$qsubscript(""x($C(2147483713))"",1)",$qsubscript("x($C(2147483713))",1),"")
	do chk("$qsubscript(""x(""""a""""_$C(4294967361))"",1)",$qsubscript("x(""a""_$C(4294967361))",1),"a")
	do chk("$qsubscript(""x($C(65))"",1)",$qsubscript("x($C(65))",1),"A")
	quit
	;
loadchk	; Check MUPIP LOAD of load.zwr loaded only ^x(3), whose $C() argument fits in an int
	new sub,list
	set sub="",list="" for  set sub=$order(^x(sub)) quit:""=sub  set list=list_$select(""=list:"",1:",")_$zwrite(sub)
	do chk("the list of ^x subscripts loaded",list,3)
	do chk("^x(3)",$get(^x(3)),"A")
	quit
	;
trig	; Trigger -pieces= values, and pattern repeat counts in a trigger subscript, too large for an int
	new i,line,spec
	for i=1:1 set line=$text(trigtab+i) quit:""=$piece(line,";",2)  do
	. set spec=$piece(line,";",2)
	. write "# Command : write $ztrigger(""item"","_$zwrite(spec)_")",!
	. do chk("$ztrigger(""item"")",$ztrigger("item",spec),$piece(line,";",3))
	do chk("$ztrigger(""select"") output",$$select,"+^a -commands=S -delim="","" -pieces=2 -xecute=""set y=1""")
	quit
	;
trigtab	; trigger definition;expected $ztrigger() result
	;+^a -commands=S -xecute="set y=1" -delim="," -pieces=4294967298;0
	;+^a -commands=S -xecute="set y=1" -delim="," -pieces=2:4294967299;0
	;+^a -commands=S -xecute="set y=1" -delim="," -pieces=2147483648;0
	;+^b(?4294967297N) -commands=S -xecute="set y=1";0
	;+^c(?1.4294967297N) -commands=S -xecute="set y=1";0
	;+^d(?1(4294967297N,1A)) -commands=S -xecute="set y=1";0
	;+^e(?2147483648N) -commands=S -xecute="set y=1";0
	;+^a -commands=S -xecute="set y=1" -delim="," -pieces=2;1
	;
	;
select()	; Return the trigger definitions $ztrigger("select") writes, without its comment lines, separated by |
	new file,line,result
	set file="ydb1288_select.out",result=""
	open file:newversion use file
	if $ztrigger("select")
	close file
	open file:readonly use file
	for  read line quit:$zeof  if $length(line),";"'=$extract(line) set result=result_$select(""=result:"",1:"|")_line
	close file:delete
	quit result
	;
expect(codes) ; Return the string whose characters have the comma separated codes in codes
	new i,s
	set s="" for i=1:1:$length(codes,",") quit:""=$piece(codes,",",i)  set s=s_$char($piece(codes,",",i))
	quit s
	;
chk(desc,actual,expect) ; Print PASS if actual is expect, and WRONG otherwise
	if actual=expect write "PASS : ",desc," returned ",$zwrite(actual),! quit
	write "WRONG : ",desc," returned ",$zwrite(actual),", expected ",$zwrite(expect),!
	quit
