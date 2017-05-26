alternate
	set a="test"
	set e="e1"
	open a:(comm="./echoback":stderr=e)::"pipe"
	write !,"zshow after open",!!
	zshow "d"
	write !
	set $ztrap="goto cont1"
	use e
	write "expect to fail",!
	use $p
	write "we should not get here",!
cont1	use a
	write "line one",!
	write "line two",!
	write "line three",!
	write "line four",!
  
	write /eof
	use a
	for  read x quit:$zeof  use $p write "line= ",x,! use a
	use e
	for  read x quit:$zeof  use $p write "eline= ",x,! use e
	close e
	; demonstrate that a close of the error device, which is the current device, will return to principal device
	write !,"zshow after closing ""e1"" only:",!!
	zshow "d"
	close a
	write !,"zshow after closing ""test"":",!!
	zshow "d"

	; The following is to demonstrate "e1" and "test" are both closed when "test" is closed	and that
	; current device returns to the principal device if the last "use" was for the stderr device
	set a="test"
	set e="e1"
	open a:(comm="boguscommand":stderr=e)::"pipe"
	write !,"zshow after open",!!
	zshow "d"
	use e
	read x
	close a
	if ""'=x write x,!
	write !,"zshow after closing ""test"":",!!
	zshow "d"
	quit
