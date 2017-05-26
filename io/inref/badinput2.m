badinput
	write "Testing for the non-fixed case in utf mode",!
	write "Testing input of the phrase ""This is a test"" where no newline is returned, but we want to get partial input",!
	write "For the read x:0 case we are testing to make sure it doesn't hang",!!
	set p="test"
	o p:(comm="./strip_cr")::"pipe"
	zshow "d"
	use $p
	write !,"testing r x:0",!
	use p
	do ^u10
	for  read x:0 q:x'=""
	set z=$za
	set t=$test
	set k=$device 
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	write !,"testing r x:5",!
	use p
	do ^u10
	read x:5
	set z=$za
	set t=$test
	set k=$device 
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	c p
	write !,"Testing for the fixed case in utf mode",!
	write "Testing input of the phrase ""This is a test"" where no newline is returned, but we want to get partial input",!
	write "strip_cr will strip out the newline and all spaces, so input will be less than recordsize",!!
	o p:(comm="./strip_cr 1":fixed:recordsize="30")::"pipe"
	zshow "d"
	write !,"testing r x:0",!
	use p
	do ^u10
	for  read x:0 q:x'=""
	set z=$za
	set t=$test
	set k=$device 
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	write !,"testing r x:5",!
	use p
	do ^u10
	read x:5
	set z=$za
	set t=$test
	set k=$device 
	use $p
	write "->",x,"<-",!
	write "$device = ",k," $za = ",z," $test = ",t,!
	quit
