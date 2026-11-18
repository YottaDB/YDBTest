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
; $FIND() and $EXTRACT() of strings with BADCHARs in UTF-8 mode, after an earlier $FIND() or $EXTRACT()
; of the same string (see r208/u_inref/utfcgr_badchar-ydb1406.csh)
ydb1406	; Each stage runs in its own process, in UTF-8 mode. The strings are longer than 33 bytes, because
	; shorter strings do not use the cache of character groups.
	quit
stage1	; A string that starts with a BADCHAR. The calls with VIEW "BADCHAR" stop at the BADCHAR, and the calls with
	; VIEW "NOBADCHAR" then use the cache that those calls leave.
	new s,k
	set s=$zchar(220)_"abcdefghijklmnopqrstuvwxyz,0123456789"
	write "# VIEW ""BADCHAR""",!
	for k=1:1:5 do chk("$find(s,"","","_k_")","ERR BADCHAR")
	view "NOBADCHAR"
	write "# VIEW ""NOBADCHAR""",!
	do chk("$extract(s,1)","VAL $ZCH(220)")
	do chk("$extract(s,2)","VAL ""a""")
	do chk("$find(s,"","",1)","VAL 29")
	do chk("$find(s,"","",5)","VAL 29")
	quit
stage2	; A BADCHAR after three ASCII characters. The first call caches the three ASCII characters. The calls with
	; VIEW "BADCHAR" stop at the BADCHAR, and the calls with VIEW "NOBADCHAR" then use the cache that those calls leave.
	new s
	set s="abc"_$zchar(200)_"defghijklmnopqrstuvwxyz,0123456789"
	write "# VIEW ""BADCHAR""",!
	do chk("$extract(s,3)","VAL ""c""")
	do chk("$extract(s,4)","ERR BADCHAR")
	do chk("$extract(s,3,4)","ERR BADCHAR")
	do chk("$extract(s,5)","ERR BADCHAR")
	do chk("$find(s,"","",4)","ERR BADCHAR")
	do chk("$find(s,"","",5)","ERR BADCHAR")
	do chk("$extract(s,2,3)","VAL ""bc""")
	view "NOBADCHAR"
	write "# VIEW ""NOBADCHAR""",!
	do chk("$extract(s,4)","VAL $ZCH(200)")
	do chk("$extract(s,3,4)","VAL ""c""_$ZCH(200)")
	do chk("$extract(s,5)","VAL ""d""")
	do chk("$find(s,"","",4)","VAL 29")
	quit
stage3	; Three BADCHARs after three ASCII characters, cached with VIEW "NOBADCHAR" and then used with VIEW "BADCHAR"
	new s
	set s="abc"_$zchar(200,201,202)_"defghijklmnopqrstuvwxyz,0123456789"
	view "NOBADCHAR"
	write "# VIEW ""NOBADCHAR""",!
	do chk("$extract(s,6)","VAL $ZCH(202)")
	do chk("$extract(s,7)","VAL ""d""")
	do chk("$find(s,"","",6)","VAL 31")
	view "BADCHAR"
	write "# VIEW ""BADCHAR""",!
	do chk("$extract(s,3)","VAL ""c""")
	do chk("$extract(s,4)","ERR BADCHAR")
	do chk("$extract(s,5)","ERR BADCHAR")
	do chk("$extract(s,6)","ERR BADCHAR")
	do chk("$extract(s,7)","ERR BADCHAR")
	do chk("$find(s,"","",6)","ERR BADCHAR")
	quit
stage4	; Random $FIND() and $EXTRACT() calls of random strings of ASCII, multi-byte characters and BADCHARs, with
	; VIEW "BADCHAR" and VIEW "NOBADCHAR" at random. Each call is made with the string, which may use the cache
	; of earlier calls, and with a new copy of the string, which has no cache. The two results must match.
	new seed,i,nops,mism,nstr
	set seed=$zcmdline if 'seed set seed=$random(2147483647)+1
	write "seed=",seed,!	; to run the same strings and calls again : mumps -run stage4^ydb1406 <seed>
	set (nops,mism)=0,nstr=500
	for i=1:1:nstr do one(i)
	if 'mism write "PASS : each of the random $FIND() and $EXTRACT() calls of ",nstr," random strings gave the same result for the string and for a new copy of the string",!
	else  write "FAIL : ",mism," of ",nops," random $FIND() and $EXTRACT() calls gave a result for the string that differs from the result for a new copy of the string",!
	quit
one(i)	; One random string and 40 random calls
	new s,t,j,n,op,k,k2,expr,r1,r2
	set s="",n=$$rnd(14)+2
	for j=1:1:n set s=s_$$chunk()
	for op=1:1:40 do
	. if '$$rnd(8) view $select($$rnd(2):"NOBADCHAR",1:"BADCHAR")
	. set k=$$rnd($zlength(s)+3),k2=k+$$rnd(6)
	. set expr=$select($$rnd(2):"$find(X,"","","_k_")",$$rnd(2):"$extract(X,"_k_")",1:"$extract(X,"_k_","_k2_")")
	. set t=$zextract(s,1,$zlength(s)-1)_$zextract(s,$zlength(s))	; a new copy of s
	. set r1=$$try($$sub(expr,"s")),r2=$$try($$sub(expr,"t"))
	. set nops=nops+1
	. quit:r1=r2
	. set mism=mism+1
	. write "MISMATCH : string ",i," call ",op," : ",$$sub(expr,$zwrite(s))," with VIEW ",$select($view("BADCHAR"):"",1:"NO"),"BADCHAR : ",r1," for the string, ",r2," for a new copy",!
	view "BADCHAR"
	quit
sub(expr,name)	; expr with name in place of X
	quit $piece(expr,"X",1)_name_$piece(expr,"X",2)
rnd(m)	; A pseudorandom integer from 0 to m-1, from seed
	set seed=(seed*1103515245+12345)#2147483648
	quit seed\65536#m
chunk()	; 0 to 20 ASCII characters, one multi-byte character or one byte that is not a valid character
	new t,r,c
	set t=$$rnd(10)
	if t<5 set r="" for c=1:1:$$rnd(21) set r=r_$zextract("abcxyz,, ",$$rnd(9)+1)
	if t<5 quit r
	if t=5 quit $char(233)
	if t=6 quit $char(8364)
	if t=7 quit $char(128512)
	if t=8 quit $zchar(128+$$rnd(128))
	quit $zchar(195)
chk(expr,expect)	; Evaluate expr and print PASS if the result is expect, else FAIL
	new r
	set r=$piece($$try(expr),",",1)
	write $select(r=expect:"PASS",1:"FAIL")," : ",expr," : ",r
	write:r'=expect " (expected ",expect,")"
	write !
	quit
try(expr)	; "VAL "_$ZWRITE(value of expr), or "ERR "_the mnemonic and the text of the error that expr raises
	new v,r,$etrap
	set $etrap="set r=""ERR ""_$piece($piece($zstatus,"","",3,99),""-"",3,99),$ecode="""" quit"
	xecute "set v="_expr
	quit $get(r,"VAL "_$zwrite($get(v)))
