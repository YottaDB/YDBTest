;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Large portions of this test are based upon the v63005/gtm5574 test
; which have been modified to ensure that the test will fail if the
; ydb652 bug is present.
	set maxr(17,1)=6
	set maxr(16,5)=3
	set maxr(15,2)=10
	set maxr(14,9)=3
	set maxr(13,2)=2
	set maxr(12,1)=6
	set maxr(11,5)=1
	set maxr(10,0)=5
	set maxr(9,4)=7
	set maxr(8,6)=1
	set maxr(7,0)=7
	set maxr(6,6)=9
	set maxr(5,8)=5
	set maxr(4,4)=7
	set maxr(3,6)=10
	set maxr(2,9)=8
	set maxr(1,7)=6
	for i=1:1:10  do
	. write !,"Start iteration ",i," of test",!
	. do test
	quit

; This routine is the core of the test. It is run 10 times to ensure
; that it generates at least 1 random integer that will fail if
; the ydb652 bug is present. This test runs in seconds so running
; it 10 times will not slow anything down.
test
	do genrandint
	zsystem "echo 'ibase=10;obase=16; "_n_";' |bc > hex.txt"
	set h="hex.txt"
	open h
	use h
	read nhex
	zsystem "echo 'ibase=10;obase=8; "_n_";' |bc > oct.txt"
	set o="oct.txt"
	open o
	use o
	close h
	read noct
	use $p
	close o
	set %DH=n
	do ^%DH
	do verify(nhex,%DH,16)
	write:(status=0) "%DH-----Correct Conversion",!
	write:(status'=0) "FAILED: DH= ",%DH,"   bcoutput= ",nhex,"   diff=",status,!

	set %HO=%DH
	do ^%HO
	do verify(noct,%HO,8)
	write:(status=0) "%HO-----Correct Conversion",!
	write:(status'=0) "FAILED: HO= ",%HO,"   bcoutput= ",noct,!

; This generates a random 19 digit (in base 10) integer
; that will be converted to base 16 and then from base 16
; to base 8. It is designed to generate a random integer
; between 1000000000000000000 and 1152921504606846975.
; This is the range of numbers where the ydb652 bug is
; present in $HO on upstream versions V6.3-009 and later.
; It uses the following variables:
; n: the random integer that it is generating. Digits are
;    generated from left to right and concatenated onto
;    the integer
; l: the number of digits remaining to generate
; maxr: This is a number between 1 and 10. It is passed to
;       $random to ensure that this routine does not generate
;       a random integer greater than 1152921504606846975. If
;       the final result is guaranteed to be less than
;       1152921504606846975 due to previously selected random
;       numbers, it will always be 10.
genrandint
	set n=1
	set l=18
	set maxr=2
	for  quit:l=0  do
	. set r=$random(maxr)
	. set n=n_r
	. set l=l-1
	. set maxr=$get(maxr(l,r),10)
	quit

; This routine verifies that the conversion performed by %DH
; or %HO was correct by comparing the result of the conversion
; to the result of an equivalent conversion in bc
verify(bcout,percentout,ibase)
	set zsyst="echo 'ibase="_ibase_"; "_percentout_"-("_bcout_");' | bc > verify.out"
	zsystem zsyst
	set v="verify.out"
	open v
	use v
	read status
	close v
	use $p
	set:$ZCMDLINE<0 status=status#(2**($select(ibase=8:3,ibase=16:4)*$length(percentout)))
	quit
