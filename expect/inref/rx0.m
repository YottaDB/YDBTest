;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; rx0.m
rx0	new
	zshow "d":devices
	; in order run this test correctly, $PRINCIPAL must be a terminal
	if devices("D",1)'["TERMINAL"  write "WARNING: ",devices("D",1)," is not a TERMINAL",!
	set cnt=0
	read x:0
	if  set cnt=cnt+1 write !,x,"was just read.",!
	set file="rx0.expected"
	open file:newversion
	use file
	write $select(cnt:"FAIL",1:"PASS")," from ",$text(+0),!
	close file
	quit
