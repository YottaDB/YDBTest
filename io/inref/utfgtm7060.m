;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper routine for io/gtm7060 to test $X set greater than width in UTF-8 mode
; All of these tests produce the same result with or without the gtm7060 fix
; The width and recordsize are defined to test with some multi-byte UTF-8 characters
utfgtm7060
	; In each case $X will exceed width.  Try writes which exceed the width to show wrap/nowrap.
	set testn=$zcmdline
	if ""=testn write "utfgtm7060 <utest1|utest2|utest3|utest4|utest5|utest6>",! quit
	set f=testn_".out"
	set out1="""1234567890ՇՈՉABCՏՐՇՈՉABCՏՐՇՈՉABCՏՐ012345"",!"
	set out2="""1234567890ՇՈՉABCՏՐՇՈՉABCՏՐՇՈՉABCՏՐ012"""
	do @$zcmdline
	quit
utest1
	; since $X is greater than width the first write will insert a newline then
	; complete the wrapped write of the 2 output lines
	open f:newversion
	use f:width=37
	do dowrite("utest1, variable with wrap:",out1)
	quit
utest2
	; since $X is greater than width and it is nowrap, the first write will only be a newline
	; the second write will stop at width and terminate with a newline
	open f:newversion
	use f:(width=37:nowrap)
	do dowrite("utest2, variable with nowrap:",out1)
	quit
utest3
	; for fixed utf with wrap the current record starts with $X=38 so it writes 52 spaces followed by 2 37
	; character records
	open f:(newversion:fixed:recordsize=52)
	use f:width=37
	do dowrite("utest3, fixed with wrap:",out2)
	quit
utest4
	; For fixed utf with nowrap the current record starts with $X=38 resulting in 52 spaces
	open f:(newversion:fixed:recordsize=52)
	use f:(width=37:nowrap)
	do dowrite("utest4, fixed with nowrap:",out2)
	quit
utest5
	; for stream utf with wrap it is the same output as utest1
	open f:(newversion:stream)
	use f:width=37
	do dowrite("utest5, stream with wrap:",out1)
	quit
utest6
	; No change in output with or without $X > width.
	; output is 40 chars followed by a newline followed by 40 chars and another newline.
	open f:(newversion:stream)
	use f:(width=37:nowrap)
	do dowrite("utest6, stream with nowrap:",out1)
	quit

dowrite(msg,out)
	new dout
	use $P
	write !,msg,!
	zshow "D":dout
	write dout("D",3),!
	write "Start of "_testn_" output:"
	use f
	set $X=38
	write @out
	write @out
	quit
