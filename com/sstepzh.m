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

; This is an enhanced sstep.m with the ability to print $zh in each line as it gets executed.

sstepzh(usertn);
	set %zrtn=$select(+$get(usertn):"$zpos",1:"($piece($zpos,""^"",1))")
	set $zstep="set %zsaveio=$io use $p write:$x ! write $zpos,?20,"":"" write "" "",$zh,"" : "" zprint @"_%zrtn_" use %zsaveio zstep into"
	zb sstepzh+4^sstepzh:"zstep into"
	set %zsaveio=$io use $p write !,"Stepping STARTED",!  use %zsaveio
