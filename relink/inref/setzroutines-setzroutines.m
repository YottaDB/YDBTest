;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setzroutines

;
; Generate a sequence of test cases from template M files and the
; entryref commands listed under label comText.
;
begin
	New offset
	View "NOUNDEF"
	;
	; fill in template with invocation/reference listed at comText+offset
	; template file:	base.m
        For offset=1:1 Quit:'$$commandTest^templateutils(offset,"base.m.template","base:base","bar:bar","bar:bar2")
        Write "Tests complete.",!
        Quit

	;for recursive
	;commandTest(offset,template,base,ref1,ref2)
	;$$commandTest^templateutils(offset,"base.m","base:base","bar:bar","bar:bar2")
	;$$commandTest^templateutils(offset,"template.m","bar:bar0","bar:bar","")
