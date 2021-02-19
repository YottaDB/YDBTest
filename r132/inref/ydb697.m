;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This test is heavily based upon the v63005/gtm5574 test.
; The main loop of the test generates random octal numbers from 1 digit to 10 digits
; and then runs CONVNEG^%CONVBASEUTIL on these numbers and verifies the correctness
; of the result. It also pads the numbers with zeroes at the end of the number and
; tests all such possible numbers up to 10 digits. The ydb697 bug involved octal
; numbers with 2 non-zero leading digits followed by any number of 0's resulting in
; incorrect results from CONVNEG^%CONVBASEUTIL on the V6.3-009 version of the
; function. Other combinations are tested to catch similar bugs in the future.
ydb697
	for i=1:1:10  do
	. do genrandoct(i)
	. set o=$$CONVNEG^%CONVBASEUTIL(n,8)
	. ; add leading 7's to result for verify
	. for k=$length(o):1:11  set o=7_o
	. do verify(n,o,8)
	. write:(status'=0) "Incorrect CONVNEG for -",n," result was ",o,!
	. for j=(i+1):1:10  do
	. . set n=n_0
	. . set o=$$CONVNEG^%CONVBASEUTIL(n,8)
	. . ; add leading 7's to result for verify
	. . for k=$length(o):1:11  set o=7_o
	. . do verify(n,o,8)
	. . write:(status'=0) "Incorrect CONVNEG for -",n," result was ",o,!
	write "Test complete",!
	quit

; Generates a random octal number of length l where each digit of the number is between 1 and 7.
genrandoct(l)
	set n=1+$random(7)
	set l=l-1
	for  quit:l=0  do
	. set n=n_(1+$random(7))
	. set l=l-1
	quit

; Verifies the correctness of the CONVNEG^%CONVBASEUTIL output using the bc system utility.
verify(bcout,percentout,ibase)
	set zsyst="echo 'ibase="_ibase_"; "_percentout_"+("_bcout_");' | bc > verify.out"
	zsystem zsyst
	set v="verify.out"
	open v
	use v
	read status
	close v
	use $p
	set status=status#(2**($select(ibase=8:3,ibase=16:4)*$length(percentout)))
	quit
