; This routine will trap to BADOPEN because "jjj" is an invalid command and "parse" is chosen
EX3	
	set p="test"
	open p:(shell="/bin/sh":comm="jjj":exception="g BADOPEN":stderr="e1":parse)::"pipe"
	use p:exception="G EOF"
	write "huh"
	quit
EOF	
	use $p
	write !,"here"
	quit 
BADOPEN
	use $p
	write !,"badopen error",!
	write $zstatus,!
	zshow "d"
	quit 
