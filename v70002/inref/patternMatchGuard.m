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

genpattern; main entry
	set $ztrap="goto catch"
	;
        for i=1:1:10000 do
        . set patstr=$$pat(i)
        . write "1"?@patstr
        quit

pat(depth);
        quit:depth=0 "1N"
        quit ".("_$$pat(depth-1)_")"

catch	;
	write !,"error caught: ",$piece($zstatus,",",3,4),!
	halt
