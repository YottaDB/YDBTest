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
; Helper routine for io/gtm7060 to test $X set greater than width
gtm7060
	; In each case $X will exceed width.  Try writes which exceed the width to show wrap/nowrap.
	; In all but one case setting $X > width results in a SYSTEM-E-ENO14, Bad address
	set testn=$zcmdline
	if ""=testn write "gtm7060 <test1|test2|test3|test4|test5|test6>",! quit
	set f=testn_".out"
	do @$zcmdline
	quit
test1
	; since $X is greater than width the first write will insert a newline then
	; complete the wrapped write of the 2 output lines
	open f:newversion
	use f:width=60
	do dowrite("test1, variable with wrap:")
	quit
test2
	; since $X is greater than width and it is nowrap, the first write will only be a newline
	; the second write will stop at width and terminate with a newline
	open f:newversion
	use f:(width=60:nowrap)
	do dowrite("test2, variable with nowrap:")
	quit
test3
	; output ignores the $X then for the first write it outputs the first 60 chars, then writes abc in next record
	; followed by 57 spaces.  This is repeated for the next write.
	open f:(newversion:fixed:recordsize=60)
	use f
	do dowrite("test3, fixed with wrap:")
	quit
test4
	; For fixed with nowrap the first write is truncated with no output.  The second is truncated at width chars.
	; similar to test2 but without inserted newlines
	open f:(newversion:fixed:recordsize=60)
	use f:nowrap
	do dowrite("test4, fixed with nowrap:")
	quit
test5
	; since $X is greater than width the first write will insert a newline then
	; complete the wrapped write of the 2 output lines - same as test1
	open f:(newversion:stream)
	use f:width=60
	do dowrite("test5, stream with wrap:")
	quit
test6
	; no error for this one even without gtm7060 fix.  No change in output with or without $X > width.
	; output is 63 chars followed by a newline followed by 63 chars and another newline.
	open f:(newversion:stream)
	use f:(width=60:nowrap)
	do dowrite("test6, stream with nowrap:")
	quit

dowrite(msg)
	new dout
	use $P
	write !,msg,!
	zshow "D":dout
	write dout("D",3),!
	write "Start of "_testn_" output:"
	use f
	set $X=80
	write "123456789012345678901234567890123456789012345678901234567890abc",!
	write "123456789012345678901234567890123456789012345678901234567890abc",!
	quit
