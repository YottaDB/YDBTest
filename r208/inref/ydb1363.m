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
ydb1363	; Called by r208/u_inref/zycompile_param-ydb1363.csh. Each label is a stage and writes what $ZYCOMPILE() returns.
	quit
maxargcnt	; MAXARGCNT, whose message has the parameter !UL
	new a,i
	set a=" set x=a" for i=1:1:300 set a=a_"_a"
	write "$zycompile=",$zycompile(a),!
	quit
badcase	; BADCASECODE, whose message has the parameter !AD
	write "$zycompile=",$zycompile(" set x=$zconvert(""a"",""Q"")"),!
	quit
foroflow	; FOROFLOW, whose message has the parameter !UL
	new a,i
	set a=" for i1=1:1:1" for i=2:1:40 set a=a_" for i"_i_"=1:1:1"
	write "$zycompile=",$zycompile(a),!
	quit
twoerrs	; two errors with parameters on one line: $ZYCOMPILE() returns the first one
	write "$zycompile=",$zycompile(" set a=$zconvert(""a"",""Q""),b=$zconvert(""a"",""R"")"),!
	quit
noparm	; an error with a parameter, then an error without one, in the same process
	write "$zycompile=",$zycompile(" set x=$zconvert(""a"",""Q"")"),!
	write "$zycompile=",$zycompile(" set x=$piece(""a"""),!
	quit
invdlrcval	; INVDLRCVAL in UTF-8 mode, whose message has the parameter !UL
	write "$zycompile=",$zycompile(" set x=$char(10000000)"),!
	quit
