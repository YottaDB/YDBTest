;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
ydb1068
	write "# Test 1 : DEFAULT ZSHOW ""D""",!
	ZSHOW "D"
	write "# Test 2 : Randomized option",!
	write "# This test will pick one value from each group {TTSYNC,NOTTSYNC}, {HOSTSYNC,NOHOSTSYNC}",!
	write "# and {CONVERT,NOCONVERT} then applying it.",!
	write "# After that, run ZSHOW ""D"" and check if output correct or not.",!
	write "# Then test it for 10 times.",!
	; Initialize array of option
	new ttopt,hostopt,convopt
	set ttopt="TTSYNC|NOTTSYNC"
	set hostopt="HOSTSYNC|NOHOSTSYNC"
	set convopt="CONVERT|NOCONVERT"
	new iter
	; Do it 10 times
	for iter=1:1:10  do
	. k out
	. set randttopt=$zpiece(ttopt,"|",$random($zlength(ttopt,"|"))+1)
	. set randhostopt=$zpiece(hostopt,"|",$random($zlength(hostopt,"|"))+1)
	. set randconvopt=$zpiece(convopt,"|",$random($zlength(convopt,"|"))+1)
	. set x="$principal:"_randttopt
	. use @x
	. set y="$principal:"_randhostopt
	. use @y
	. set z="$principal:"_randconvopt
	. use @z
	. new file set file="zshowd.out"
	. open file:append
	. use file
	. write "Iteration: ",iter,!
	. write "Option list#1 {TTSYNC,NOTTSYNC}:",randttopt,", #2 {HOSTSYNC,NOHOSTSYNC}:",randhostopt,", #3 {CONVERT,NOCONVERT}:",randconvopt,!
	. zshow "D"
	. close file
	. zshow "D":out
	. write "Iteration: ",iter,!
	. ; For ttsync
	. if out("D",1)[(" "_randttopt_" ") write "PASS for TTSYNC",!
	. else  write "FAIL for TTSYNC in iteration : ",iter,!
	. ; For hostsync
	. if out("D",1)[(" "_randhostopt_" ") write "PASS for HOSTSYNC",!
	. else  write "FAIL for HOSTSYNC in iteration : ",iter,!
	. ; For convert
	. if randconvopt="CONVERT"  DO
	. . if out("D",1)[(" "_randconvopt_" ") write "PASS for CONVERT",!
	. . else  write "FAIL for CONVERT in iteration :",iter,!
	. if randconvopt="NOCONVERT"  DO
	. . if out("D",1)'["CONVERT" write "PASS for CONVERT",!
	. . else  write "FAIL for CONVERT in iteration : ",iter,!
	; Reset HOSTSYNC to NOHOSTSYNC just in case
	use $principal:nohostsync
	quit
	;
