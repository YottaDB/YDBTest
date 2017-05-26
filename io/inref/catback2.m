catback2:
	use $p:width=120
	set m1="ttest"
	open m1:(command="cat -u")::"pipe"
	use m1
	; make sure $test starts with 1
	if 1
	read x:5
	set t=$test
	set za=$za
	set d=$device
	use $p
	write "x:5 timing out, $test = ",t," $za = ",za," $device = ",d," ->",x,"<-",!
	use m1
	write "Test line one",!
	for  read x:5 quit:x'=""
	set t=$test
	set za=$za
	set d=$device
	use $p
	write "x:5 not timing out, $test = ",t," $za = ",za," $device = ",d," ->",x,"<-",!
	use m1
	; make sure $test starts with 1
	if 1
	read x:0
	set t=$test
	set za=$za
	set d=$device
	use $p
	write "x:0 timing out, $test = ",t," $za = ",za," $device = ",d," ->",x,"<-",!
	use m1
	write "Test line two",!
	for  read x:0 quit:x'=""
	set t=$test
	set za=$za
	set d=$device
	use $p
	write "x:0 not timing out, $test = ",t," $za = ",za," $device = ",d," ->",x,"<-",!
	; make sure $test is not changed by a read without timeout
	; it is currently 1 or the previous line will fail
	use m1
	w "The value of $test before read x is 1.  The value of $test after read x is ",!
	r x
	set t=$test
	use $p
	w x,t,!
	use m1
	read x:0
	; $test will be zero after timeout
	; it should stay zero after another read without timeout
	w "The value of $test before read x is 0.  The value of $test after read x is ",!
	r x
	set t=$test
	use $p
	w x,t,!
	close m1
	write "Create pipe device handles p1-p4",!
	set p1="test1"
	set p2="test2"
	set p3="test3"
	set p4="test4"
	open p1:(shell="/bin/sh":command="cat -u")::"pipe"
	set a=p1
	write a,!
  	do ^back10
	open p2:(shell="/bin/sh":command="cat -u")::"pipe"
	set a=p2
	write a,!
	do ^back10
	open p3:(newversion:shell="/usr/local/bin/tcsh":command="cat -u")::"pipe"
	set a=p3
	write a,!
	do ^back10
	open p4:(command="cat -u")::"pipe"
	set a=p4
	write a,!
	do ^back10
	write "Execute zshow to see which devices are open",!!
	zshow "d"	      
	close p1
	close p2
	close p3
	close p4
	write "Execute zshow to show the pipe devices are closed",!!
	zshow "d"	      
	q
