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
zpinandzpout
	; $P will be redirected so that input comes from /dev/null and output goes to zpinandzpout.outx
	; this allows us to see the operation of USE for $PRINCIPAL, $ZPIN, and $ZPOUT since WRAP/NOWRAP applies
	; to both sides.  Show attempt to open $ZPIN or $ZPOUT issues an error message.
	set $ztrap="goto errorAndCont^errorAndCont"
	write "Demonstrate USE $P, $ZPOUT, and $ZPIN for a split device",!
	write "Demonstrate error message while attempting to open $ZPIN or $ZPOUT",!!
	zshow "d"
	write "$PRINCIPAL = ",$p,!
	write "$ZPIN = ",$zpin,!
	write "$ZPOUT = ",$zpout,!
	; turn wrap on both sides
	use $p:wrap
	zshow "d"
	use $zpout:nowrap
	zshow "d"
	set t="tfile"
	open t:newversion
	use t
	write "TEST OPEN and USE a file with a split $PRINCIPAL works fine",!
	use $zpin:nowrap
	zshow "d"
	use t:rewind
	read x
	use $P
	write x,!
	; cause an open error trying to open $zpin
	open $zpin
	; cause an open error trying to open $zpout
	open $zpout
	zshow "d"
	quit
