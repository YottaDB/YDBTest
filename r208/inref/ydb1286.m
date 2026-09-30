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
; YDB#1286 : $ZWRITE(str,1) must return the empty string for any str that is not a complete ZWRITE format
; string, and must not look at the bytes that follow str in memory.
;
; $EXTRACT() and $ZEXTRACT() return a string that shares memory with their source, so a prefix of a ZWRITE
; format string taken that way is followed in memory by the rest of that string. Each label below is run by
; zwr2str_invalid-ydb1286.csh.
;
ydb1286	;
	write "Run one label at a time. See zwr2str_invalid-ydb1286.csh",!
	quit
	;
truncated ; Prefixes of a valid ZWRITE format string, taken with $EXTRACT() so the rest of the string follows them
	new i,line,x,n
	for i=1:1 set line=$text(trunctab+i) quit:""=$piece(line,";",2)  do
	. set x=$piece(line,";",2),n=$piece(line,";",3)
	. do chkprefix(x,n,$piece(line,";",4))
	quit
	;
trunctab ; ZWRITE format string;length of the prefix;expected result
	;"X"_$C(65);5;
	;"X"_$ZCH(65);6;
	;"X"_$ZCH(65);7;
	;"X"_$C(65);6;
	;"X"_$C(65);9;
	;"X"_$ZCH(65);11;
	;"X"_$C(65);10;XA
	;"X"_$ZCH(65);12;XA
	;
	;
truncutf8 ; A prefix that ends in a $C() argument that is a valid character only in UTF-8 mode
	do chkprefix("""X""_$C(1234)",11,"")
	do chkprefix("""X""_$C(1234)",12,"X"_$char(1234))
	quit
	;
chkprefix(x,n,expect) ; Check $ZWRITE($EXTRACT(x,1,n),1) returns expect
	new y
	set y=$extract(x,1,n)
	do chk("$zwrite(y,1) with y="_y_", the first "_n_" characters of "_x,$zwrite(y,1),expect)
	quit
	;
invalid	; Strings that are not valid ZWRITE format strings on their own
	new i,line,y
	for i=1:1 set line=$text(invtab+i) quit:""=$piece(line,";",2)  do
	. set y=$piece(line,";",2)
	. do chk("$zwrite(y,1) with y="_y,$zwrite(y,1),$piece(line,";",3))
	quit
	;
invtab	; string;expected result
	;"X"_$C(;
	;"X"_$ZCH(;
	;$C(65,;
	;"X"_;
	;"X"_$C(65)_;
	;"X"_"Y;
	;"a"";
	;"X"_$C(65)Y;
	;_"X";
	;-;
	;.;
	;-.;
	;1.;
	;"X"_"Y";XY
	;"a""";a"
	;"X"_$C(65,66)_$ZCH(67);XABC
	;"";
	;1;1
	;-1;-1
	;.5;.5
	;-.5;-.5
	;-1.5;-1.5
	;12;12
	;123;123
	;
	;
randm	; Random ZWRITE format strings in M mode
	do random(0)
	quit
	;
randutf8 ; Random ZWRITE format strings in UTF-8 mode, where $C() also takes code points above 255
	do random(1)
	quit
	;
random(utf8) ; Build random ZWRITE format strings from tokens, and check $ZWRITE(prefix,1) for every prefix of each.
	; A prefix is valid only if it ends with a complete token, or inside a quoted string at the first " of a
	; doubled "", and then it must return what it holds, decoded. Every other prefix must return the empty
	; string. Each prefix is taken with $ZEXTRACT() so the rest of the string follows it in memory.
	new cnt,ntok,i,z,val,valid,k,p,expect,r,wrong,nstr
	set cnt=0,wrong=0,nstr=2000
	for i=1:1:nstr do  quit:10<wrong
	. set ntok=1+$random(4),z="",val=""
	. kill valid
	. for k=1:1:ntok do
	. . set:k>1 z=z_"_"
	. . do token(utf8,.z,.val,.valid)
	. . set valid($zlength(z))=val
	. for k=1:1:$zlength(z) do
	. . set p=$zextract(z,1,k),r=$zwrite(p,1),cnt=cnt+1
	. . set expect=$get(valid(k))
	. . quit:r=expect
	. . set wrong=wrong+1
	. . write "WRONG : $zwrite(p,1) with p=",p,", the first ",k," bytes of ",z," returned ",$zwrite(r)
	. . write ", expected ",$zwrite(expect),!
	if wrong write "WRONG : ",wrong," prefix(es) wrong out of ",cnt," checked before stopping",!
	else  write "PASS : every prefix of ",nstr," random ZWRITE format strings returned its expected value",!
	quit
	;
token(utf8,z,val,valid) ; Append a random token to the ZWRITE format string z, and its decoded value to val
	new t,n,j,c,s
	set t=$random(3),s=""
	if 0=t do  quit
	. ; a quoted string of 0 to 5 printable ASCII characters, with each " doubled
	. set z=z_""""
	. for j=1:1:$random(6) set c=$char(32+$random(95)) do
	. . set:""""=c valid($zlength(z)+1)=val_s
	. . set z=z_$select(""""=c:"""""",1:c),s=s_c
	. set z=z_"""",val=val_s
	; $C() or $ZCH() of 1 to 3 codes
	set n=1+$random(3)
	if 1=t do  quit
	. for j=1:1:n do
	. . if 'utf8 set c=$random(256)
	. . else  for  set c=$random($select($random(2):256,1:1114112)) quit:$$ischar(c)
	. . set s=s_$select(1<j:",",1:"")_c,val=val_$char(c)
	. set z=z_"$C("_s_")"
	for j=1:1:n set c=$random(256),s=s_$select(1<j:",",1:"")_c,val=val_$zchar(c)
	set z=z_"$ZCH("_s_")"
	quit
	;
loadchk	; Check MUPIP LOAD of load.zwr loaded only ^x(6), the one record that is a complete ZWRITE format string
	new sub,list
	set sub="",list="" for  set sub=$order(^x(sub)) quit:""=sub  set list=list_$select(""=list:"",1:",")_sub
	do chk("the list of ^x subscripts loaded",list,6)
	do chk("^x(6)",$get(^x(6)),"XA")
	quit
	;
trig	; A trigger -delim= value that is not a complete ZWRITE format string must be rejected
	new i,line,spec
	for i=1:1 set line=$text(trigtab+i) quit:""=$piece(line,";",2)  do
	. set spec="+^a -commands=S -xecute=""set y=1"" -delim="_$piece(line,";",2)
	. write "# Command : write $ztrigger(""item"","_$zwrite(spec)_")",!
	. do chk("$ztrigger(""item"") with -delim="_$piece(line,";",2),$ztrigger("item",spec),$piece(line,";",3))
	do chk("$ztrigger(""select"") output",$$select,"+^a -commands=S -delim=""a""_$C(9) -xecute=""set y=1""")
	quit
	;
trigtab	; -delim= value;expected $ztrigger() result
	;"a"_;0
	;"a"_$C(;0
	;"a"_$C(9)_;0
	;"a"_$C(9);1
	;
	;
select()	; Return the trigger definitions $ztrigger("select") writes, without its comment lines, separated by |
	new file,line,result
	set file="ydb1286_select.out",result=""
	open file:newversion use file
	if $ztrigger("select")
	close file
	open file:readonly use file
	for  read line quit:$zeof  if $length(line),";"'=$extract(line) set result=result_$select(""=result:"",1:"|")_line
	close file:delete
	quit result
	;
ischar(c) ; Return 1 if the code point c is a character, that is neither a surrogate nor a noncharacter
	quit '(((55296'>c)&(57343'<c))!((64976'>c)&(65007'<c))!(65533<(c#65536)))
	;
chk(desc,actual,expect) ; Print PASS if actual is expect, and WRONG otherwise
	if actual=expect write "PASS : ",desc," returned ",$zwrite(actual),! quit
	write "WRONG : ",desc," returned ",$zwrite(actual),", expected ",$zwrite(expect),!
	quit
