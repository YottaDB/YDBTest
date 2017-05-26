;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8417
	set $ETRAP="zwrite $zstatus zhalt 1"
	do text^dollartext("nonzero^gtm8417","nonzero.m")  ; Restore the routine to non-zero length
	do istep^gtm8417
	set ^a(1)=$increment(^a(3))
	quit

; Initialize the test setup
init
	do text^dollarztrigger("trig^gtm8417","gtm8417.trg")
	do file^dollarztrigger("gtm8417.trg",1)
	zsystem "touch zero"
	quit

; Do some conflicting updates
a	set ^a(2)=$increment(^a(4)) quit
b	do recompile set ^b(2)=$increment(^b(4)) quit

; Copy a null file over nonzero.m, compile and zrupdate it. Reload triggers to force a recompile in the main process
recompile
 	zsystem "cp zero nonzero.m"
	zcompile "nonzero.m"
	zrupdate $zdirectory_"*"
	do file^dollarztrigger("gtm8417.trg",1)
	quit

; Internal sstep to make the test case self contained
istep
	set $zstep="set %zsaveio=$io use $p write:$x ! write $zpos,?20,"":"" zprint @($piece($zpos,""^"",1)) use %zsaveio zstep into"
	zbreak istep+3^gtm8417:"zstep into"
	set %zsaveio=$io use $p write !,"iStepping STARTED",!  use %zsaveio
	quit

; Non-zero length routine to execute inside the trigger. The zsystem will nullify this routine and cause a restart due to external conflict updates
nonzero
	;nonzero
	;	zsystem "$gtm_dist/mumps -run b^gtm8417"
	;	set ^b(1)=$increment(^b(3))
	;quit
	quit

; Trigger routine for the test case
trig
	;-*
	;+^a(1) -commands=SET -xecute="do ^nonzero zsystem:$trestart=1 ""$gtm_dist/mumps -run a^gtm8417"""
