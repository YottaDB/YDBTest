; This test expects to take the EOF1 trap and then tries to read from stderr where it
; will get a version of "command not found" and write it to ex4.log

EX4	
	set p="test"
	open p:(shell="/bin/sh":comm="kkk":exception="g BADOPEN":stderr="e1")::"pipe"
	use p:exception="G EOF1"
	; expect to trap to EOF1
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
	write "look in ex4.log for stderr output",!
	use "e1":exception="G EOF2"
	read y
	set a=$zeof
	use $p
	; write the output line if something there from stderr
	set ex4="ex4.log"
	open ex4
	use ex4
	if 'a write "y = ",y,!
	close ex4
	use $p
	write "END OF FILE SEEN",!
	zshow "d"
	quit 
EOF2	use $p
	write "EOF2",!
	write "Nothing in stderr",!
	close p
	quit
BADOPEN
	use $p
	write !,"badopen error",!
	write $zstatus,!
	zshow "d"
	quit 
