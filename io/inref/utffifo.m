utffifo
	set p2="fifo2.test"
	write "Testing fifo for the non-fixed case in utf mode",!
	write "Testing input of 10 utf characters produced by u10.m with newline and normal termination",!
	open p2:(fifo:newversion)
	zshow "d"
	write !,"testing r x:0 with newline so no timeout",!
	zsystem "$gtm_dist/mumps -run u10 > fifo2.test"
	use p2
	for  read x:0 q:x'=""
	set z=$za
	set t=$test
	set k=$device
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	write !,"testing r x:5 with newline so no timeout",!
	zsystem "$gtm_dist/mumps -run u10 > fifo2.test"
	use p2
 	read x:5
	set z=$za
	set t=$test
	set k=$device
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	close p2	

	write "Testing fifo for the fixed case in utf mode",!
	write "Testing input of 10 utf characters and expect normal termination",!
	open p2:(fifo:newversion:fixed:recordsize=20)
	zshow "d"
	write !,"testing r x:0",!
	zsystem "$gtm_dist/mumps -run u10 | ./strip_cr > fifo2.test"
	use p2
	read x:0
	set z=$za
	set t=$test
	set k=$device
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	write !,"testing r x:5",!
	zsystem "$gtm_dist/mumps -run u10 | ./strip_cr > fifo2.test"
	use p2
 	read x:5
	set z=$za
	set t=$test
	set k=$device
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	quit
