fifovarread
	; we will use mytest.fifo for actual variable tests.  We will use sync1.fifo for the reader to request 
	; transmissions, and sync2.fifo for the writer to say when it is done with a write to mytest.fifo.
	set cnt=0
	set ftest="mytest.fifo"
	set sync1="sync1.fifo"
	set sync2="sync2.fifo"
	open ftest:(fifo:readonly)
	open sync1:(fifo:writeonly:newversion)
	open sync2:(fifo:readonly)
	if $zversion["OS390" set ^readready=1
	use ftest
	read x:0 
	set za=$za,zeof=$zeof,d=$device,t=$test
	use $p
	write "read x:0 with no input and expect:",!,"$za = 0 $zeof = 0 $device = 0 $test = 0",!
	write "$za = ",za," $zeof = ",zeof," $device = ",d," $test = ",$test,!
	use ftest
	read x:1 
	set za=$za,zeof=$zeof,d=$device,t=$test
	use $p
	write "read x:1 with no input and expect:",!,"$za = 0 $zeof = 0 $device = 0 $test = 0",!
	write "$za = ",za," $zeof = ",zeof," $device = ",d," $test = ",t,!

	; have writer send "abcdefghijklmnopqrstuvwxyz" with newline to test normal termination of read x:1
	use sync1
	write "send 1",!
	; wait for response before read from ftest
	use sync2
	read x
	use ftest
	read x:1
	set za=$za,zeof=$zeof,d=$device,t=$test
	use $p
	write "read x:1 with normal termination of input and expect:",!,"$za = 0 $zeof = 0 $device = 0 $test = 1",!
	write "$za = ",za," $zeof = ",zeof," $device = ",d," $test = ",t,!
	if ""'=x write x,!

	; have writer send "abcdefghijklmnopqrstuvwxyz" with newline to test normal termination of read x:0
	use sync1
	write "send 2",!
	; wait for response before read from ftest
	use sync2
	read x
	use ftest
	read x:0
	set za=$za,zeof=$zeof,d=$device,t=$test
	use $p
	write "read x:0 with normal termination of input and expect:",!,"$za = 0 $zeof = 0 $device = 0 $test = 1",!
	write "$za = ",za," $zeof = ",zeof," $device = ",d," $test = ",t,!
	if ""'=x write x,!

	; have writer send "abcdefghijklmnopqrstuvwxyz" without newline to test partial read timeout
	use sync1
	write "send 3",!
	; wait for response before read from ftest
	use sync2
	read x
	use ftest
	read x:1
	set za=$za,zeof=$zeof,d=$device,t=$test
	use $p
	write "read x:1 with partial input and expect:",!,"$za = 0 $zeof = 0 $device = 0 $test = 0",!
	write "$za = ",za," $zeof = ",zeof," $device = ",d," $test = ",t,!
	if ""'=x write x,!

	; have writer send "abcdefghijklmnopqrstuvwxyz" without newline to test partial read timeout
	use sync1
	write "send 4",!
	; wait for response before read from ftest
	use sync2
	read x
	use ftest
	read x:0
	set za=$za,zeof=$zeof,d=$device,t=$test
	use $p
	write "read x:0 with partial input and expect:",!,"$za = 0 $zeof = 0 $device = 0 $test = 0",!
	write "$za = ",za," $zeof = ",zeof," $device = ",d," $test = ",t,!
	if ""'=x write x,!

	; have writer send "abcdefghijklmnopqrstuvwxyz",! to test normal read
	use sync1
	write "send 5",!
	; wait for response before read from ftest
	use sync2
	read x
	use ftest
	read x
	set za=$za,zeof=$zeof,d=$device,t=$test
	use $p
	write "read x with normal termination of input and expect:",!,"$za = 0 $zeof = 0 $device = 0",!
	write "$za = ",za," $zeof = ",zeof," $device = ",d,!
	if ""'=x write x,!
	write "First part done",!
	; tell writer he can quit
	use sync1
	write "all done",!
	; give him time to quit
	hang 5

	; do some zeof tests
	use ftest
	read x:1
	set za=$za,zeof=$zeof,d=$device,t=$test
	use $p
	write "read x:1 getting end of file expect:",!,"$za = 9 $zeof = 1 $device = 1,Device detected EOF $test = 1",!
	write "$za = ",za," $zeof = ",zeof," $device = ",d," $test = ",t,!

	use sync2
	read x:0
	set za=$za,zeof=$zeof,d=$device,t=$test
	use $p
	write "read x:0 getting end of file expect:",!,"$za = 9 $zeof = 1 $device = 1,Device detected EOF $test = 1",!
	write "$za = ",za," $zeof = ",zeof," $device = ",d," $test = ",t,!
	write "Second part done",!
	write !,"Try to write to readonly fifo",!
	set $ztrap="goto BAD"
	use sync2
	write "test",!	
	quit

BAD	use $p
	write $zstatus,!
	; try and write to readonly fifo
	if 0=cnt do
	. write !,"Try to read from writeonly fifo",!
	. set cnt=1
	. use sync1
	. read x
	halt
	
