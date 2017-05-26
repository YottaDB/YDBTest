unicodefixedlen(encoding)
	;Test unicode fixed length reads
	set $ZTRAP="do error"
	set file="unicodefixedlen.txt"
	do open^io(file,"NEWVERSION",encoding)
	use file
	write "｀ａｂｃｄｅｆｇ",!
	write "生まれながらにして自由であり、",!
	use $PRINCIPAL
	write "Will test a valid fixed len (1048576)",!
	use file:(rewind)
	for i=1:1 use file read line#1048576 quit:$ZEOF  do	;should be successful
	. use $PRINCIPAL
	. write "The length of variable line read was:",$LENGTH(line),!
	. zwr line
	use $PRINCIPAL
	write "Will test an invalid fixed len (1048577)",!
	use file:(rewind)
	for i=1:1 use file read line#1048577 quit:$ZEOF		;should report RDFLTOOLONG error
	use $PRINCIPAL
	quit
error	new $ZTRAP
	use $PRINCIPAL
	write $ZSTATUS,!
	halt
