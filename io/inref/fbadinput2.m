fbadinput2
	write "Testing fifo for the non-fixed case in utf mode",!
	write "Testing input of 10 utf characters produced by u10.m where no newline is returned, but we want to get partial input",!
	set p="fifo.test"
	set p2="fifo2.test"
	open p:(fifo:newversion)
	zshow "d"
	write !,"testing r x:0",!
	zsystem "$gtm_dist/mumps -run u10 | ./strip_cr > fifo.test"
	use p
	for  read x:0 q:x'=""
	set z=$za
	set t=$test
	set k=$device 
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	write !,"testing r x:5",!
	zsystem "$gtm_dist/mumps -run u10 | ./strip_cr > fifo.test"
	use p
	read x:5
	set z=$za
	set t=$test
	set k=$device
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	close p
	write !,"Testing fifo for the fixed case in utf mode",!
	write "Testing input of the phrase of 10 utf characters produced by u10.m where no newline is returned,",!
	write "strip_cr will strip out the newline so input will be less than recordsize",!!
	open p2:(fifo:newversion:fixed:recordsize=30)
	zshow "d"
	write !,"testing r x:0",!
	zsystem "$gtm_dist/mumps -run u10 | ./strip_cr > fifo2.test"
	use p2
	for  read x:0 q:x'=""
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
