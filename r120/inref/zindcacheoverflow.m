;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 Finxact, LLC. and/or its subsidiaries.     ;
; All rights reserved.                                          ;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test to check that the reporting of indirect code cache performance statistics does not encounter a 4-byte overflow error
;
; Methodology:
;   Run 43 million set operations, then check that the hit ratio is 99%. If it is zero %, the cache hits counter might have a numeric overflow bug
;
zindcacheoverflow()
	for i=1:1:22000000 xecute "set @""x""=1"
	halt
