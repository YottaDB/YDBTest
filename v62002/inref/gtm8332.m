;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8332	;
	quit

start	;
	set jmaxwait=0
	do ^job("child^gtm8332",1,"""""")
	quit

stop	;
	do wait^job
	quit

child	;
	set ^a=1
	quit

timecheck;
	new i,max
	for  read line($incr(i))  quit:$zeof
	kill line(i)  if $incr(i,-1)
	set max=i
	; line(i) now points to an array of journal extract lines
	set prev=0
	for i=1:1:max do
	. set time=$piece(line(i),"\",2)
	. if time="" quit  ; those lines that dont contain a timestamp ignore them (e.g. first line contains "YDBJDX07")
	. set time=$piece(time,",",1)*24*60*60+$piece(time,",",2)
	. if prev>time write "Time Verification FAILED",!  zshow "*"  halt
	. set prev=time
	if prev=0 write "Time Verification FAILED",!  zshow "*"  halt  ; should have seen at least one journal record
	write "Time Verification PASSED",!
	quit
