;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
ydb1364	; READ of a UTF-8 file whose CR line terminator is the last byte in the READ buffer [YDB#1364]
	; Runs case number $ZCMDLINE of the table below. The case writes <n> "x" characters, CR, the bytes <tail> and LF to
	; a file, READs the file in UTF-8 mode until $ZEOF, and checks the list of results (L<length of the record> for a
	; READ, E<mnemonic> for a READ that issued an error, EOF for the READ that sets $ZEOF) against <expect>. The READ
	; after the last LF of a file returns an empty record before a READ sets $ZEOF.
	new spec,n,tailspec,tail,expect,f,i,res,eof,x
	set spec=$piece($text(cases+$zcmdline),";;",2)
	set n=$piece(spec,";",1),tailspec=$piece(spec,";",2),expect=$piece(spec,";",3)
	set tail="" for i=1:1:$length(tailspec,",") set tail=tail_$zchar($piece(tailspec,",",i))
	set f="ydb1364_case"_$zcmdline_".txt"
	open f:(newversion:chset="M") use f write $translate($justify("",n)," ","x"),$char(13),tail,$char(10) close f
	open f:(readonly:chset="UTF-8")
	set res="",eof=0
	for i=1:1:10 do read quit:eof
	close f
	use $principal
	write "# ",n," x characters, CR, $ZCHAR(",tailspec,"), LF",!
	if res=expect write "PASS : READ results are ",res,!
	else  write "FAIL : READ results are ",res," but ",expect," was expected",!
	quit
read	new $etrap
	set $etrap="set res=res_$select(res="""":"""",1:"" "")_""E""_$piece($piece($zstatus,""-E-"",2),"","",1),$ecode="""" quit"
	use f read x set eof=$zeof
	set res=res_$select(res="":"",1:" ")_$select(eof:"EOF",1:"L"_$length(x))
	quit
cases	; <n>;<tail bytes>;<expect>
	;;2;152;L2 EBADCHAR L0 EOF
	;;8194;152;L8194 EBADCHAR L0 EOF
	;;16386;152;L16386 EBADCHAR L0 EOF
	;;2;195,40;L2 EBADCHAR L0 EOF
	;;2;195,169;L2 L1 L0 EOF
	;;8194;195,169;L8194 L1 L0 EOF
	;;3;152;L3 EBADCHAR L0 EOF
	;;8193;152;L8193 EBADCHAR L0 EOF
	;;3;195,40;L3 EBADCHAR L0 EOF
	;;3;195,169;L3 L1 L0 EOF
	;;8194;89;L8194 L1 L0 EOF
