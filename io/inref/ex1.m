; This routine will trap to BADOPEN because the shell "jjj" is invalid
EX1	
	set p="test"
	open p:(shell="jjj":comm="cat -u":exception="g BADOPEN")::"pipe"
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
