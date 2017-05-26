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
gtm7971	;test that extrinics in Booleans compiled with gtm_boolean (full_boolean) don't indefinite loop
	;prior to gtm7971 all the Boolean expressions in the body of the "child" below would go into
	;indefinite loops and cause a TEST-E-JOBWAITTOOLONG in the parent
	;if the test fails with an indefinite loop the child process runs wild and must be killed by hand
	new (act)
	if '$data(act) new act set act="goto fail"
	set full="Standard"=$piece($view("full_boolean")," ")
	view "jobpid":1				; tack the pid onto the child output files
	set jmaxwait=30,jnolock=1		; non-zero implies max absolute seconds to wait for children to die
	do ^job("child^gtm7971",1,"""""")	; start 1 background process that does child^gtm7971
	set jpid=$zjob
	set file="child_gtm7971.mjo1."_jpid
	open file:readonly
	use file read x,y,z set zeof=$zeof
	close file
	if "d child^gtm7971"'=x!($select(full:"abbaabbaa0b0b0a0",1:"0000")'=y)!(""'=z)!'zeof xecute act quit
	set file="child_gtm7971.mje1."_jpid
	open file:readonly
	use file read z set zeof=$zeof
	close file
	if (""'=z)!'zeof xecute act quit
	write !,"PASS from ",$text(+0)
	quit
child	; if all is well this does not hang and writes abbaabbaa0b0b0a0 to the .mjo
	set $etrap="goto fail"
	if $get(x)&($$a&$get(a)'=0) write "x"
	if '$get(x)&($get(b)&$$b'=0) write "x"
	if $get(b)=1&$$b'=0&'$get(x) write "x"
	if '$get(x)&$get(b)=1&$$a'=0 write "x"
	write:$get(x)&($$a&$get(a)'=0) "x"
	write:'$get(x)&($get(b)&$$b'=0) "x"
	write:$get(b)=1&$$b'=0&'$get(x) "x"
	write:'$get(x)&$get(b)=1&$$a'=0 "x"
	write $get(x)&($$a&$get(a)'=0)
	write '$get(x)&($get(b)&$$b'=0)
	write $get(b)=1&$$b'=0&'$get(x)
	write '$get(x)&$get(b)=1&$$a'=0
	quit
a()	write "a"
	quit 0
b()	write "b"
	quit 0
fail	write !
	zshow "*"
	write !,"FAIL from ",$text(+0),!
	quit
