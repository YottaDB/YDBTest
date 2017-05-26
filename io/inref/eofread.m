eofread
	; show read x:0 and x:2 produce correct $za, $device, $zeof, and $test values
	; show that $test doesn't change when a ztrap is taken
	set cnt=0
	set p="test"
	open p:(shell="/usr/local/bin/tcsh":comm="cat")::"pipe"
	use p
	; close the pipe to simulate a process dying
	write /eof
	set p2="test2"
	open p2:(shell="/usr/local/bin/tcsh":comm="cat")::"pipe"
	use p2
	; close the second pipe to simulate a process dying
	write /eof
	use p
	; set $test to 0
	if 0
	for i=1:1:60 hang 1 read x:2 quit:$zeof
	set a=$zeof
	set b=$za
	set k=$device 
	set t=$test
	use $p
	write !,"doing read x:2",!
	write "$zeof = ",a,!
	write "$za = ",b,!
	write "$device = ",k,!
	write "$test = ",t,!

	use p2
	; set $test to 0
	if 0
	for i=1:1:60 hang 1 read x:0 quit:$zeof
	set a=$zeof
	set b=$za
	set k=$device 
	set t=$test
	use $p
	write !,"doing read x:0",!
	write "$zeof = ",a,!
	write "$za = ",b,!
	write "$device = ",k,!
	write "$test = ",t,!
	write !,"try and read again to force a $ztrap ",!
	use p2
	set $ztrap="goto BAD"
	; do a read with a trap to show that $test doesn't change for traps
	if 0
	read x:1
	quit 

BAD	set a=$zeof
	set b=$za
	set k=$device 
	set t=$test
	use $p	
	write "$zeof = ",a,!
	write "$za = ",b,!
	write "$device = ",k,!
	if 0=cnt do
	. write !,"expect 0 since we did if 0, $test = ",t,!,!
	. write "try and read again to force another $ztrap ",!
	. set cnt=1
	. use p
	. if 1
	. read x:1
	else  write !,"expect 1 since we did if 1, $test = ",t,!,!
	write $zstatus,!
	halt
