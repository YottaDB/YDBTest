read	read "file to read: ",fr,!
	open fr:(read:exception="G notfound")
	zshow "D"
	use fr:exception="G eof"
	for  use fr read line use $p zwrite line
	quit
eof	if '$zeof zm +$zstatus
	close fr
	quit
notfound if $zstatus["-FNF," do  quit
	. write !,"The file ",fr," does not exist.",!
	if $zstatus["-PRV," do  quit
	. write !,"The file ",fr," is not accessible.",!
	zm +$zstatus
	quit
write	read "file to create: ",fw,!
	open fw:new
	zshow "D"
	use fw
	write "this is line 1",!
	write "this is the second line",!
	write "this is the last line",!
	close fw
	quit
