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
;   Run 44 million indirection operations (each of the 22 million set operations results in 2 indirect cache hits), then check that the hit ratio is 99%.
;  The hit ratio used have a numeric overflow bug resulting in a hit ratio of 0%.
;  The 44 million value is chosen because in the hit ratio calculation, 44 million is multiplied by 100 to get 4.4 billion, overflowing a 4-byte integer.
;  We use indirection in the set operation lhs to prevent the compiler from optimizing out the xecute.
;
zindcacheoverflow()
	for i=1:1:22000000 xecute "set @""x""=1"
	halt
