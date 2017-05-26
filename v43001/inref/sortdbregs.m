sortdbregsinmsg01
	; For lines matching: Cannot backup database regions <reg1> and <reg2> ...
	; ensures <reg1> sorts before <reg2>.  Other lines passed through unchanged.
	new line,reg1,reg2
	for  read line quit:$zeof  do
	. if $length(line)&$find(line,"Cannot backup database regions ") do
	.. set reg1=$piece(line," ",5),reg2=$piece(line," ",7)
	.. if reg1']reg2 write line,!
	.. else  write $piece(line," ",1,4)," ",reg2," and ",reg1," ",$piece(line," ",8,$length(line," ")),!
	.else  write line,!
	quit
