;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fbadinput
	write "Testing fifo for the non-fixed case in M mode",!
	write "Testing input of the phrase ""This is a test"" where no newline is returned, but we want to get partial input",!
	write "For the read x:0 case we are testing to make sure it doesn't hang",!!
	set p="fifo.test"
	open p:(fifo:newversion)
	zshow "d"
	write !,"testing r x:0",!
	zsystem "echo ""This is a test"" | ./strip_cr > fifo.test"
	use p
	for  read x:0 quit:x'=""
	set z=$za
	set t=$test
	set k=$device
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	write !,"testing r x:5",!
	zsystem "echo ""This is a test"" | ./strip_cr > fifo.test"
	use p
	read x:5
	set z=$za
	set t=$test
	set k=$device
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	close p
	write !,"Testing fifo for the fixed case in M mode",!
	write "Testing input of the phrase ""Testing fixed"" where no newline is returned, but we want to get partial input",!
	write "strip_cr will strip out the newline and all spaces, so input will be less than recordsize",!!
	open p:(fifo:newversion:fixed:recordsize=20)
	zshow "d"
	write !,"testing r x:0",!
	zsystem "echo ""Testing fixed"" | ./strip_cr 1 > fifo.test"
	use p
	for  read x:0 quit:x'=""
	set z=$za
	set t=$test
	set k=$device
	; need to set $x to 0 as it will now be set to the size of the read x:0 and the next read will be incomplete
	set $x=0
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	write !,"testing r x:5",!
	zsystem "echo ""Testing fixed"" | ./strip_cr 1 > fifo.test"
	use p
	read x:5
	set z=$za
	set t=$test
	set k=$device
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	quit
