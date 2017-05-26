;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
C9L03003393	;
	write "This routine should not be invoked as-is without a accompanying label.",!
	quit

setupLargeKeys		; Create globals with large subscript lengths
	set subs=""
	for i=33:1:72  set subs=subs_$char(i)
	set ^aglobalvar(subs)="aValue"
	set ^bglobalvar(subs)="bValue"
	set ^cglobalvar(subs)="cValue"
	set ^subs=subs
	quit

; Test various GT.M commands and ensure that they all work fine. Some of these commands uses a non existent subscript. However, they
; have to first create a gv_currkey including that non-existent subscript and that is where GT.M versions <= V5.4-002 will FAIL
; with an assert in DBG and GTMASSERT in PRO.

init	;
	quit

testWrite ;
	set $etrap="do etr"
	set errallowed(1)="GVSUBOFLOW"	; add GVSUBOFLOW to list of allowed errors
	;
	view "NOISOLATION":"+^aglobalvar,^bglobalvar,^cglobalvar"
	write !,"Testing WRITE...",!
	; In some cases, the below global reference might be mapped to the DEFAULT region in which case
	; we would get a GVSUBOFLOW error first (and not the expected GVUNDEF error). Filter out both
	; those errors and display only any other error so as to keep reference file deterministic.
	set errallowed(2)="GVUNDEF"	; add GVUNDEF to list of allowed errors only for this test case
	set x=^aglobalvar(^subs,"NONEXISTENTSUBSCRIPT")
	quit

testDollarGet ;
	set $etrap="do etr"
	set errallowed(1)="GVSUBOFLOW"	; add GVSUBOFLOW to list of allowed errors
	;
	view "NOISOLATION":"+^aglobalvar,^bglobalvar,^cglobalvar"
	write !,"Testing $GET...",!
	set x=$get(^bglobalvar(^subs,"NONEXISTENTSUBSCRIPT"))
	quit

testKill ;
	set $etrap="do etr"
	set errallowed(1)="GVSUBOFLOW"	; add GVSUBOFLOW to list of allowed errors
	;
	view "NOISOLATION":"+^aglobalvar,^bglobalvar,^cglobalvar"
	write !,"Testing KILL...",!
	kill ^cglobalvar(^subs,"NONEXISTENTSUBSCRIPT")
	quit

testDollarOrder ;
	set $etrap="do etr"
	set errallowed(1)="GVSUBOFLOW"	; add GVSUBOFLOW to list of allowed errors
	;
	view "NOISOLATION":"+^aglobalvar,^bglobalvar,^cglobalvar"
	write !,"Testing $order...",!
	set x=$order(^aglobalvar(^subs,"NONEXISTENTSUBSCRIPT"))
	quit

testDollarZPrevious ;
	; no error (GVSUBOFLOW or GVUNDEF) is expected in this case so "set $etrap" is not invoked
	view "NOISOLATION":"+^aglobalvar,^bglobalvar,^cglobalvar"
	write !,"Testing $zprevious...",!
	write $zprevious(^bglobalvar("")),! ; $zprevious will create internally a large subscript with lots of $c(255)
	quit

testDollarData	;
	set $etrap="do etr"
	set errallowed(1)="GVSUBOFLOW"	; add GVSUBOFLOW to list of allowed errors
	;
	view "NOISOLATION":"+^aglobalvar,^bglobalvar,^cglobalvar"
	write !,"Testing $DATA...",!
	set x=$data(^cglobalvar(^subs,"NONEXISTENTSUBSCRIPT"))
	quit

testSet	;
	set $etrap="do etr"
	set errallowed(1)="GVSUBOFLOW"	; add GVSUBOFLOW to list of allowed errors
	;
	view "NOISOLATION":"+^aglobalvar,^bglobalvar,^cglobalvar"
	write !,"Testing SET...",!
	set ^aglobalvar(^subs,"NONEXISTENTSUBSCRIPT")="aNewValue"
	quit

etr	;
	; There are a list of allowed errors maintained in "errallowed()" variable. Anything else is considered an error.
	; Even inside the allowed errors, if the error is GVSUBOFLOW check that the reference displayed matches
	; $reference and that it maps to the DEFAULT region (and not AREG, BREG or CREG) as that is the only region capable
	; of issuing the GVSUBOFLOW error. If the allowed error is GVUNDEF, check that the global reference displayed
	; in $zstatus matches $reference and in turn matches ^aglobalvar(^subs,"NONEXISTENTSUBSCRIPT").
	; Any error outside of the allowed error list is a real error.
	if '$data(errallowed) zshow "*" halt
	set errindex="",expectederr=1
	for  set errindex=$order(errallowed(errindex))  quit:errindex=""  do
	. set err=errallowed(errindex),errid=$piece($zstatus,",",1)
	. if (("GVSUBOFLOW"=err)&(150372986=errid)) do  quit
	. . if '($zstatus[($zextract($reference,1,$zl($reference)-1))) set expectederr=0	; ignore * vs ) (last character)
	. . if $view("REGION",$reference)'="DEFAULT" set expectederr=0
	. if (("GVUNDEF"=err)&(150372994=errid)) do  quit
	. . if '($zstatus[reference) set expectederr=0
	. . if '(reference'=$name(^aglobalvar(^subs,"NONEXISTENTSUBSCRIPT"))) set expectederr=0
	. if ("GVUNDEF"=err) quit
	. if ("GVSUBOFLOW"=err) quit
	. set expectederr=0
	if 'expectederr write $zstatus,!
	quit
