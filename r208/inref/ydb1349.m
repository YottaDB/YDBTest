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
; Helper M program used by the r208/qsubscript_env_zero-ydb1349 subtest. Each label checks the results of functions
; that parse a global name with an environment, and prints PASS or WRONG.
;
envzero	; Second environment part is the number 0
	do check("^[1,0]a(5)","1|1|^a|5")
	quit
envzerozero	; Both environment parts are the number 0, 2 subscripts
	do check("^[0,0]a(5,6)","2|0|^a|5|6")
	quit
envchar	; Second environment part is $CHAR() or $ZCHAR()
	do check("^[1,$C(65)]a(5)","1|1|^a|5")
	do check("^[1,$ZCH(65)]a(5)","1|1|^a|5")
	do check("^[1,""x""_$C(66)]a(5)","1|1|^a|5")
	quit
name	; $NAME(@n,depth) of such names
	do checkname("^[1,0]a(5,6)",1,"^[1,0]a(5)")
	do checkname("^[1,0]a(5,6)",0,"^[1,0]a")
	do checkname("^[1,$C(65)]a(5,6)",1,"^[1,""A""]a(5)")
	quit
zcollate	; $ZCOLLATE() of such a name, converted back to a name
	new n,act,z
	set n="^[1,0]a(5,6)"
	do
	. new $etrap
	. set $etrap="set act=$piece($zstatus,"","",3),$ecode="""" quit"
	. set act=$zcollate($zcollate(n,0),0,1)
	if "^a(5,6)"=act write "PASS : $ZCOLLATE($ZCOLLATE(""",n,""",0),0,1) returned ",act,!
	else  write "WRONG : $ZCOLLATE($ZCOLLATE(""",n,""",0),0,1) returned ",act," instead of ^a(5,6)",!
	; $VIEW("YGVN2GDS") uses the same conversion of a name to its database form as $ZCOLLATE()
	do
	. new $etrap
	. set $etrap="set act=$piece($zstatus,"","",3),$ecode="""" quit"
	. set act=$view("YGDS2GVN",$view("YGVN2GDS",n))
	if "^a(5,6)"=act write "PASS : $VIEW(""YGDS2GVN"",$VIEW(""YGVN2GDS"",""",n,""")) returned ",act,!
	else  write "WRONG : $VIEW(""YGDS2GVN"",$VIEW(""YGVN2GDS"",""",n,""")) returned ",act," instead of ^a(5,6)",!
	quit
unchanged	; Names that already gave the right results
	do check("^[1,2]a(5)","1|1|^a|5")
	do check("^[""0"",""0""]a(5)","1|0|^a|5")
	do check("^[0]a(5)","1|0|^a|5")
	do check("^|0|a(5)","1|0|^a|5")
	do check("^[0,1]a(5)","1|0|^a|5")
	do check("^a(0,0,""0"")","3||^a|0|0|0")
	; A subscript, or the first environment part, that ends with $CHAR() records its stop offset
	do check("^a(1,$C(65))","2||^a|1|A")
	do check("^a(""x""_$C(66))","1||^a|xB")
	do check("^[$C(65),2]a(5)","1|A|^a|5")
	do check("^|""x""_$C(66)|a(5)","1|xB|^a|5")
	quit
check(n,expect)
	; Check "$QLENGTH(n)|$QSUBSCRIPT(n,-1)|$QSUBSCRIPT(n,0)|$QSUBSCRIPT(n,1)|..." against expect
	new act,i
	set act=$qlength(n)
	for i=-1:1:$qlength(n) set act=act_"|"_$qsubscript(n,i)
	if act=expect write "PASS : ",n," : $QLENGTH and $QSUBSCRIPT(-1 to ",$qlength(n),") are ",act,!
	else  write "WRONG : ",n," : $QLENGTH and $QSUBSCRIPT(-1 to ",$qlength(n),") are ",act," instead of ",expect,!
	quit
checkname(n,depth,expect)
	new act
	set act=$name(@n,depth)
	if act=expect write "PASS : $NAME(@""",n,""",",depth,") is ",act,!
	else  write "WRONG : $NAME(@""",n,""",",depth,") is ",act," instead of ",expect,!
	quit
