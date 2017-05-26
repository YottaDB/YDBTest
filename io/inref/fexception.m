;Just making sure we don't break normal disk file exception handling
;This just tests the trap for a normal file by creating it readonly and then trying to write to it
;If we want to get the "not accessible" message then create "jjjl" and chmod to 000.
FEXCEPTION   
	set sd="jjjl"
	set EEXIST=$SELECT($ZV["OS390":129,1:2)
	set EACCESS=$SELECT($ZV["OS390":111,1:13)
	open sd:(readonly:exception="g BADOPEN") 
	use sd:exception="G EOF" 
	for  use sd read x use $p write x,! 
EOF	if '$zeof zm +$zs 
	close sd 
	quit 
BADOPEN
	if $p($zs,",",1)=EEXIST do  quit 
	. write !,"The file  ",sd," does not exist.",!
	. zshow "d"
	if $p($zs,",",1)=EACCESS do  quit 
	. write !,"The file ",sd," is not accessible.",! 
	. zshow "d"
	zm +$zs 
	quit 
