;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2007, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; C9H11-002926: Don't allow relink of routine currently on the GTM stack. This issue was raised because insufficient checking was
; being done to verify that a module being relinked was not in fact on the stack. If the module that is on the stack is not using
; the most current routine header (because the module had been replaced one or more times but there existed references to the
; earlier versions) the code prior to this fix did not detect that because it was only checking the most current version of the
; routine header. This test triggers the failing case that the fix cures by relinking modules that are on the stack repeatedly
; until it fails.
C9H11002926
	new (act)
	if '$data(act) new act set act="write !,$zstatus"
	set (cnt,iter)=0
	new $etrap,$estack
	set $etrap="xecute:$zlevel-1=$stack(-1) act quit:$estack>1  set cnt=cnt+1,$ecode="""""
	zsystem $select($zversion["VMS":"copy",1:"cp")_" zlinktst2A.m zlinktst2.m"
	for i="A","B","C" do 
	.	set iter=iter+1
	.	do ^zlinktst2
	.	quit
	write !,$select(cnt=iter:"PASS",1:"FAIL")," from C9H11002926",!
	quit 
