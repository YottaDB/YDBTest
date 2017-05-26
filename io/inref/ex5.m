; This starts a dummy command called "kkk" which is executable in the current directory.  It tries to read from the 
; pipe and then expects to take the EOF1 trap and then tries to read from stderr which will trap to EOF2

EX5	
	zsystem "touch kkk"
	zsystem "chmod 755 kkk"
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
	write "try stderr",!
	use "e1":exception="G EOF2"
	read y
	set a=$zeof
	use $p
	; write the output line if something there from stderr
	open "ex5.log"
	use "ex5.log"
	if 'a write "y = ",y,!
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
