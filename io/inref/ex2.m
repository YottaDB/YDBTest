; This starts a cat with a standard error return also.  It writes one line and reads one line and then writes
; an eof to close the pipe (simulating a crash of the cat process).  It then expects to take the EOF1 trap and
; then tries to read from stderr which will trap to EOF2 since there is nothing there.
EX2
	set p="test"
	open p:(shell="/usr/local/bin/tcsh":comm="cat -u":exception="g BADOPEN":stderr="e1")::"pipe"
	use p:exception="G EOF1"
	write "Doing one write",!
	read x
	use $p
	write x,!
	use p
	; close the pipe to simulate a process dying
	write /eof
	for  read x:0 quit:x'=""
	use $p
	write x,!
	write "shouldn't be here",!
	quit
EOF1	set a=$zeof
	set b=$za
	set k=$device 
	use $p
	write "$zeof = ",a,!
	write "$za = ",b,!
	write "$device = ",k,!
	write "EOF1",!
	write $zstatus,!
	write "try stderr",!
	use "e1":exception="G EOF2"
	read y
	set a=$zeof
	use $p
	; write the output line if something there from stderr
	if 'a write "y = ",y,!
  	write "END OF FILE SEEN",!
	zshow "d"
	close p
	quit 
EOF2	use $p
	write "EOF2",!
	write "Nothing in stderr",!
	zshow "d"
	close p
	quit
BADOPEN
	use $p
	write !,"badopen error",!
	zshow "d"
	close p
	quit 
