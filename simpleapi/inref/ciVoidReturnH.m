;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; callin from C SimpleAPI
; compares toPass, to cmpStr(type) (they are the same literals) and makes sure they are the same
ciStringProc(toPass,type)
	set cmpStr(1)="Far out in the uncharted backwaters of the"
	set cmpStr(2)="unfashionable end of the western spiral arm"

	set length=$length(cmpStr(type)," ")
	if length'=$length(toPass," ") write "The length of the strings do not match cmpStr: ",length," toPass: ",$length(toPass," "),!
	for i=1:1:5 set n=$random(length) set x=$piece(cmpStr(type)," ",n) set y=$piece(toPass," ",n) if x'=y write "The string does not match at word ",n," cmpStr: ",x," toPass: ",y,!
	quit
