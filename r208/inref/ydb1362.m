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
; XECUTE of string literals with a complement of a number that is too large (see r208/u_inref/xecute_lit_numoflow-ydb1362.csh)
;
ydb1362	;
	quit
	;
gen	; Write one routine x<case>.m per case below. Each routine XECUTEs the string literal of the case, which sets "got",
	; under an $ETRAP that sets "got" to the mnemonic of the error, and then writes "got".
	new i,line,name,code
	for i=1:1 set line=$text(cases+i) quit:line=" quit"  do
	. set name=$piece(line,";",2),code=$piece(line,";",3,999)
	. open "x"_name_".m":newversion use "x"_name_".m"
	. write "x"_name,$char(9),"set $etrap=""set got=$piece($zstatus,"""","""",3) set $ecode="""""""" write got,! halt""",!
	. write $char(9),code,!
	. write $char(9),"write got,!",!
	. write $char(9),"quit",!
	. close "x"_name_".m"
	. write name,!
	quit
	;
cases	; <case name>;<line that XECUTEs a string literal>
	;com;xecute "set got=1&('""1E47""!0)"
	;comonly;xecute "set got=('""1E47"")&1"
	;comcom;xecute "set got=1&(''""1E47""!0)"
	;comneg;xecute "set got=1&('-""1E47""!0)"
	;ifcom;xecute "if '""1E47""!0 set got=1"
	;neg;xecute "set got=1&(-""1E47""!0)"
	;num;xecute "set got=1&(+""1E47""!0)"
	;negcom;xecute "set got=1&(-'""1E47""!0)"
	;comsmall;xecute "set got=1&('""1""!0)"
	quit
	;
zycx	; $ZYCOMPILE of a line that XECUTEs a string literal with a complement of a number that is too large
	new q
	set q=""""
	do zyc1(" xecute "_q_"set y=1&('"_q_q_"1E47"_q_q_"!0)"_q,"")
	quit
	;
zycs	; $ZYCOMPILE of a line with a complement of a number that is too large (no XECUTE)
	new q
	set q=""""
	do zyc1(" set y=1&('"_q_"1E47"_q_"!0)","21,%YDB-E-NUMOFLOW,Numeric overflow")
	quit
	;
zyc1(line,exp)
	new got,$etrap
	set $etrap="write ""FAIL : $ZYCOMPILE issued "",$piece($zstatus,"","",3,4),! set $ecode="""""
	write "# $ZYCOMPILE(",$zwrite(line),") : expect ",$zwrite(exp),!
	set got=$zycompile(line)
	write $select(got=exp:"PASS",1:"FAIL")," : $ZYCOMPILE returned ",$zwrite(got),!
	quit
