;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Nested calls : M1 -> C -> M2,          ;
;  with $ET not explicitly set in M1 & M2 ;
;                                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
trignsterror
	if $data(^b) do
	. write "We should reach here even though it is via the call in from C (since CITPNESTED error is now nixed)"
	. halt
	set ^b=1
	write "Nested calls: M1->C->M2",!!
	write "M1:  $ZLEVEL = ",$ZLEVEL,!
	write "M1:  $STACK = ",$STACK,!
	write "M1:  $ESTACK = ",$ESTACK,!
	write "Passing:",!

	set afltp=123.349
	write "    ",afltp,!

	set adblp=654.321
	write "    ",adblp,!

	set achrp="c"
	write "    """,achrp,"""",!

	set achrpp="C-style string"
	write "    """,achrpp,"""",!

	set astrngp="String structure"
	write "    """,astrngp,"""",!

	write "to inmult",!!
	do &inmult(afltp,adblp,achrp,achrpp,astrngp)

	write !,"Values returned from inmult:",!!
	write "    ",afltp,!
	write "    ",adblp,!
	write "    """,achrp,"""",!
	write "    """,achrpp,"""",!
	write "    """,astrngp,"""",!

	write !,"Value of $ET in M1: ",$ET
	quit
error
	write !,"Error - $ET value is changed in M1"
	quit
