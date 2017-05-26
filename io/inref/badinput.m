;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2008-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
badinput
	write "Testing for the non-fixed case in M mode",!
	write "Testing input of the phrase ""This is a test"" where no newline is returned, but we want to get partial input",!
	write "For the read x:0 case we are testing to make sure it doesn't hang",!!
	set p="test"
	open p:(comm="./strip_cr")::"pipe"
	zshow "d"
	use $p
	write !,"testing r x:0",!
	use p
	write "This is a test",!
	for  read x:0 quit:x'=""
	set z=$za
	set t=$test
	set k=$device
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	write !,"testing r x:5",!
	use p
	write "This is a test",!
	for cnt=0:1:5 read x:5 quit:x'=""
	set z=$za
	set t=$test
	set k=$device
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	close p
	write !,"Testing for the fixed case in M mode",!
	write "Testing input of the phrase ""This is a test"" where no newline is returned, but we want to get partial input",!
	write "strip_cr will strip out the newline and all spaces, so input will be less than recordsize",!!
	open p:(comm="./strip_cr 1":fixed:recordsize="20")::"pipe"
	zshow "d"
	write !,"testing r x:0",!
	use p
	write "Testing fixed",!
	for  read x:0 quit:x'=""
	set z=$za
	set t=$test
	set k=$device
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	write !,"testing r x:5",!
	use p
	write "Testing fixed",!
	for cnt=0:1:5 read x:5 quit:x'=""
	set z=$za
	set t=$test
	set k=$device
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	quit
