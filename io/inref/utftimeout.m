utftimeout

	; tests a fix where read x#n:0 was successfully reading n characters from the internal buffer but
	; returned $TEST as 0 - incorrectly indicating a timeout
	; test is also executed for read x#n:1
	
	set timeout=$zcmdline
	write "executing test for read x#n:"_timeout,!
	set p="test"
	open p:(comm="cat -u")::"pipe"
	use p
	; write 8 utf characters to the pipe
	for i=997:1:1004 write $CHAR(i)
	; Since the internal buffer is empty, an actual read will be done and the 8 characters
	; will be read into an internal buffer and 4 will be emptied from the buffer - leaving 4
	; $TEST should be 1 to show no timeout
	; add a hang 10 to make sure all the characters arrive in the pipe before the reads
	hang 10
	read x#4
	use $p
	write "x= ",x,!
	; no actual read from the pipe will be done as 4 characters remain in the internal buffer.
	; The 2 characters will be emptied from the buffer - leaving 2
	; $TEST should be 1 to show no timeout
	use p
	read x#2:timeout
	set t=$TEST
	use $p
	write "$TEST = ",t,!
	write "x= ",x,!
	; We want to test edge case where 2 characters are in internal buffer.  8 more are written
	; to the pipe and the read of 3 characters with a timeout 0 returns 3 characters with no timeout.
	; Give it plenty of time so we don't return with just 2 chars and timeout.
	; $TEST should be 1 to show no timeout and 3 characters will be returned
	use p
	for i=997:1:1004 write $CHAR(i)
	hang 10
	read x#3:timeout
	set t=$TEST
	use $p
	write "$TEST = ",t,!
	write "x= ",x,!
	; Do a timed read of 8 characters, but only 7 remain in the internal buffer and the pipe is empty.
	; An actual read of the pipe will be done but will time out
	; $TEST should be 0 to show a timeout and 7 characters will be returned
	use p
	read x#8:timeout
	set t=$TEST
	use $p
	write "$TEST = ",t,!
	write "x= ",x,!
	; No data is in the internal buffer and the pipe is empty
	; An actual read of the pipe will be done but will time out
	; $TEST should be 0 to show a timeout and 0 characters will be returned
	u p
	read x#1:timeout
	set t=$TEST
	use $p
	write "$TEST = ",t,!
	write "x= ",x,!
