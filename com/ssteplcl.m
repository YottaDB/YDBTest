;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Note this routine is very similar to "com/sstepgbl.m" but records the M-line single step activity in a local variable
; instead of a global variable. This might be necessary in cases where the recording cannot be performed in a global
; variable (e.g. if most of the activity happens inside a TSTART/TCOMMIT fence but the transaction gets rolled back
; so updates to the global inside the transaction never get committed).
;
ssteplcl;
        set $zstep="set %ssteplcl($incr(%ssteplcl),$zut,$j)=$j($zpos,20)_"" : ""_$text(@$zpos) zstep into"
        zb ssteplcl+3^ssteplcl:"zstep into"
        quit
