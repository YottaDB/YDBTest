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
; Generates a random pattern of locals with fixed length values and subscripts, passes them to the child to verify their correctness
gtm4414b
	set min=$random(500)
	set max=99000+$random(1000)
	write "# Setting a pattern of locals in gtm4414b",!
	for i=min:1:max set x(i)=$justify(i,500),y($justify(i,250))=i
	job child^gtm4414b(min,max):(passcurlvn)
	do ^waitforproctodie($zjob)
	quit
child(min,max)
        for i=min:1:max do
        .       if x(i)'=$j(i,500) write "FAIL : PASSCURLVN validation failed",! zshow "*" halt
        .       if y($j(i,250))'=i write "FAIL : PASSCURLVN validation failed",! zshow "*" halt
        write "TEST-I-PASS",!
	quit
