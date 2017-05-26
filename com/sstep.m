;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2003-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	; usertn = 1 if a test wants sstep to do a ZPRINT using ^routine in the entryref
	; usertn = 0 or undefined if a test wants sstep to do ZPRINT without using ^routine in the entryref
	; By default, we do not want ^routine as that makes sstep.m not work correctly in case of recursive relinks
	;
sstep(usertn);
	set %zrtn=$select(+$get(usertn):"$zpos",1:"($piece($zpos,""^"",1))")
	set $zstep="set %zsaveio=$io use $p write:$x ! write $zpos,?20,"":"" zprint @"_%zrtn_" use %zsaveio zstep into"
	zb sstep+4^sstep:"zstep into"
	set %zsaveio=$io use $p write !,"Stepping STARTED",!  use %zsaveio
