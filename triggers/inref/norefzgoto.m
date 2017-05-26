;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
norefzgoto
	set x=$increment(y)
	do ^twork
	write:$ztlevel=3 x,":ZGOTOing from $ZTLEVEL=",$ZTLEVEL," and $ZLEVEL=",$ZLEVEL," to $zlevel=",$zlevel-($ztlevel*2),!
	zgoto:$ztlevel=3 $zlevel-($ztlevel*2) ; Two for each trigger level
	set ^a($ztlevel)=$GET(^a($ztlevel))+1
	write "Unexpected return to trigger norefzgoto at $zlevel=",$zlevel," and $ztlevel=",$ztlevel,!
	quit

	; goto while in a trigger
gotoloop
	write "$ZLevel",$zlevel,?16,"$ZTLEvel",$ZTLEvel,!
	zshow "s"
	merge ^c("a")=^a
	goto gotoloop^refzgoto
	write "$ZLevel",$zlevel,?16,"$ZTLEvel",$ZTLEvel,!
	zshow "s"
	quit

	; zgoto based on the values of depth, hence the label "controlled"
controlled(depth)
	set x=$increment(y)
	set l=$increment(^fired($ZTNAme))
	zshow "s":lstack merge ^fired($ZTNAme,l)=lstack
	; look for the trigger "+3^d#1#" by name down the stack; set default return just in case
	set trigname="+3^d#1#",return=($zlevel-(($ztlevel-2)*2))+1
	for i=1:1:$zlevel  if lstack("S",i)=trigname set return=$zlevel-(i-2) quit
	write:$ztlevel>(1+depth) x,":ZGOTOing from $ZTLEVEL=",$ZTLEVEL," and $ZLEVEL=",$ZLEVEL," to $zlevel=",return,!
	zgoto:$ztlevel>(1+depth) return ; Two for each trigger level
	set ^a($ztlevel)=$GET(^a($ztlevel))+1
	write "Unexpected return to trigger norefzgoto at $zlevel=",$zlevel," and $ztlevel=",$ztlevel,!
	quit

