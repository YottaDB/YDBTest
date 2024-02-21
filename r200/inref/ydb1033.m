;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test of YDB#1033 - Make $ZCMDLINE both SET-able and NEW-able. This test verifies that and some edge conditions
;                    that come up.
;
; Tests done:
;   1. After verifying the initial value of $ZCMDLINE (it should be NULL as it was invoked with no arguments), SET
;      a value into $ZCMDLINE so we can tell with other than a NULL string check that this is the level set in
;      the main routine.
;   2. Simple NEW of $ZCMDLINE - Do this is a lower level so we can pop back to the previous level and verify
;      the value is the one that should have been saved. Note the initial value after a NEW is the NULL string.
;   3. SET a new value in $ZCMDLINE in the lower level block and verify it worked.
;   4. Return from the inner level back to the main and verify the main level value was restored to $ZCMDLINE.
;   5. Again start a lower level and using an indirect, NEW the $ZCMDLINE ISV. Then again write it.
;   6. Then reset the value of $ZCMDLINE in the lower level routine and verify it.
;   7. Then return from the lower level routine, and verify we again have the main level version in $ZCMDLINE.
;   8. Try and indirect NEW and ZWRITE command of $ZCMDLINE in an XECUTE statement to be sure that also works.
;

;
ydb1033
	write "## Start of test YDB-1033 - test that $ZCMDLINE is both SET-able and NEW-able",!!
	write:""=$zcmdline "Current value of $ZCMDLINE is the expected NULL value - $ZLEVEL=",$zlevel,!
	if ""'=$zcmdline do
	. write "# Invalid starting value of $ZCMDLINE (unexpected) - setting it to the NULL string",!
	. set $zcmdline=""
	write !,"# Resetting $ZCMDLINE to indicate it is set at $ZLEVEL=1 in this routine",!
	set $zcmdline="$ZCMDLINE setting at the main level ($ZLEVEL="_$zlevel_")"
	zwrite $zcmdline
	do
	. new $zcmdline
	. write !,"# New level, NEW'd $ZCMDLINE and reset $ZCMDLINE to 'Let them eat icecream!', $ZLEVEL=",$zlevel,!
	. set $zcmdline="Let them eat icecream!"
	. zwrite $zcmdline
	write !,"# Level popped - Should have restored $ZCMDLINE to starting value - $ZLEVEL=",$zlevel,!
	zwrite $zcmdline
	;
	; Set $ZCMDLINE into a variable for indirect use.
	;
	set x="$zcmdline"
	do
	. write !,"# Use indirect in NEW statement and check value (should be NULL string), $ZLEVEL=",$zlevel,!
	. new @x
	. zwrite @x
	. write !,"# Now reset $ZCMDLINE (as an indirect) to something while at ZLEVEL=",$zlevel,", and ZWRITE it",!
	. set @(x_"=""Now at $ZLEVEL=""_$zlevel")
	. zwrite @x
	. write !,"# Now pop the level we are in and verify it goes back to $ZLEVEL=1 value",!
	zwrite @x
	write !,"# Do much the same thing but do it in an XECUTEd expression: 'NEW @x ZWRITE @x' - expect NULL value",!
	xecute "new @x zwrite @x"
	write !,"# And popping back to the mainline should give our ZLEVEL 1 message",!
	zwrite @x
	write !,"# Do a series of sets of $ZCMDLINE after chewing up some string pool space - make sure that the $ZCMDLINE",!
	write "# value is being correctly garbage collected. If not, the output lines below will be somewhat garbled instead",!
	write "# of being pairs of '[abcdN]' tokens where N goes in pairs from 1 to 4.",!
 	for i=1:1:4  do
 	. for j=1:1:100 set x(j)=$j(j,$random(2**10))
 	. set dst="abcd"_$j(i,"x")
 	. write "$zcmdline BEFORE set at iteration=",i," = [",$zcmdline,"]",!
 	. set $zcmdline=dst
 	. write "$zcmdline AFTER  set at iteration=",i," = [",$zcmdline,"]",!
	quit
