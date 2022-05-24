;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Valid test cases to check functionality of ZYERROR when set to entry
	; references
     	; format of entryref : label+offset^module.

SUBROUTINE1	w "Testing ZYERROR Label...",!
	s $zt="do ^ztraph"
	set $zyerror="SUBROUTINE2"
	kill x
	set x=x+1 ;bad line
	;
 	w "Testing ZYERROR Label+offset..."
        set x=0,$zyerror="SUBROUTINE3+1"
	w 1/x ;bad line
	;
    	w "Testing ZYERROR Label+module..."
        set x="",$zyerror="labelinanothermoduleforzyerror^zeleaf"
	w 1/x ;bad line
	;
	w !,"Testing ZYERROR Label+offset+module..."
        set $zyerror="labelinanothermoduleforzyerror+1^zeleaf" kill x
	set x=x+1 ;bad line

	w "end of SUB1",!
        quit

SUBROUTINE2    w "done(SUB2)",!
	do report^zeleaf
	w "end of SUB2",!
        quit

SUBROUTINE3	goto SUBROUTINE3+2
	w "done(SUB3+1)",!
	do report^zeleaf
	w "end of SUB3",!
 	quit
