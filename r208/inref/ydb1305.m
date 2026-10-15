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
; YDB#1305 : $QLENGTH, $QSUBSCRIPT and 2-argument $NAME accept a name with a $ZYSQLNULL subscript written
; as $ZYSQLNULL, which is how $NAME writes such a subscript.
;
; Each stage is run in its own process by zysqlnull_canonic_name-ydb1305.csh. A result that is the
; $ZYSQLNULL value is shown as <$ZYSQLNULL>, and an error by its mnemonic.
;
ydb1305	;
	write "Run one label at a time. See zysqlnull_canonic_name-ydb1305.csh",!
	quit
	;
names	; names that $NAME wrote, with $ZYSQLNULL subscripts in different places
	new zz,r,d
	set zz=$zysqlnull
	set r=$name(x(1,zz,"a")) write "# r = ",r,!
	do chk("$qlength(r)",3)
	do chk("$qsubscript(r,0)","x"),chk("$qsubscript(r,1)",1),chk("$qsubscript(r,2)","<$ZYSQLNULL>"),chk("$qsubscript(r,3)","a"),chk("$qsubscript(r,4)","")
	for d=0:1:3 do chk("$name(@r,"_d_")",$name(x(1,zz,"a"),d))
	set r=$name(x(zz)) write "# r = ",r,!
	do chk("$qlength(r)",1),chk("$qsubscript(r,1)","<$ZYSQLNULL>")
	for d=0:1:2 do chk("$name(@r,"_d_")",$name(x(zz),d))
	set r=$name(x(zz,"b",zz)) write "# r = ",r,!
	do chk("$qlength(r)",3),chk("$qsubscript(r,1)","<$ZYSQLNULL>"),chk("$qsubscript(r,2)","b"),chk("$qsubscript(r,3)","<$ZYSQLNULL>")
	for d=0:1:3 do chk("$name(@r,"_d_")",$name(x(zz,"b",zz),d))
	set r=$name(^g(1,zz)) write "# r = ",r,!
	do chk("$qlength(r)",2),chk("$qsubscript(r,0)","^g"),chk("$qsubscript(r,2)","<$ZYSQLNULL>")
	for d=0:1:2 do chk("$name(@r,"_d_")",$name(^g(1,zz),d))
	set r="x($zysqlnull,1)" write "# r = ",r," (lower case)",!
	do chk("$qlength(r)",2),chk("$qsubscript(r,1)","<$ZYSQLNULL>"),chk("$qsubscript(r,2)",1),chk("$name(@r,1)","x($ZYSQLNULL)")
	set r="^|$ZYSQLNULL|x(1)" write "# r = ",r," (environment)",!
	do chk("$qlength(r)",1),chk("$qsubscript(r,-1)","<$ZYSQLNULL>"),chk("$qsubscript(r,0)","^x"),chk("$name(@r,0)","^|$ZYSQLNULL|x")
	quit
	;
others	; strings that are not names with a $ZYSQLNULL subscript, whose results must be what they were before
	new r
	for r="x($ZYSQLNULLX)","x($ZYSQLNUL)","x($ZYSQLNULL","x($ZYSQLNULL)x","x(1,$ZYSQLNULL,)" do
	. write "# r = ",r,!
	. do chk("$qlength(r)","NOCANONICNAME"),chk("$qsubscript(r,1)","NOCANONICNAME")
	set r="x(""$ZYSQLNULL"")" write "# r = ",r," (a string subscript)",!
	do chk("$qlength(r)",1),chk("$qsubscript(r,1)","$ZYSQLNULL"),chk("$name(@r,1)","x(""$ZYSQLNULL"")")
	quit
	;
gvn	; a global name with a $ZYSQLNULL subscript is not a valid database key
	do chk("$zcollate(""^g(1,$ZYSQLNULL)"",0)","ZYSQLNULLNOTVALID")
	quit
	;
chk(expr,expected)	; evaluate EXPR and compare its result with EXPECTED
	new $etrap,v
	set $etrap="set v=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""" quit:$quit v  quit"
	set v=$$eval(expr)
	if v=expected write "PASS : ",expr," is ",v,!
	else  write "WRONG : ",expr," is ",v,", expected ",expected,!
	quit
eval(expr)	; EXPR's value, with the $ZYSQLNULL value shown as <$ZYSQLNULL>
	new v
	xecute "set v="_expr
	quit $select($zyissqlnull(v):"<$ZYSQLNULL>",1:v)
