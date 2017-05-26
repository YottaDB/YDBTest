readstar
	; This routine tests the read *x forms of read
	set in1=":abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz"
	use $p:width=120
	set p1="test1"
	write "input to pipe:",!
	write in1,!
	write in1,!!
	write "read *x from pipe:",!
	open p1:(command="cat -u")::"pipe"
	use p1
	write in1,!
	write in1,!
	; close the pipe with write /eof to get the end of file
	write /eof
	for  read *x quit:$zeof  use $p write $char(x) use p1
	close p1
	; test read *x:0 form
	use $p
	write !,"input to pipe:",!
	write in1,!
	write in1,!!
	write "read *x:0 from pipe:",!
	set p2="test2"
	open p2:(command="cat -u")::"pipe"
	use p2
	write in1,!
	write in1,!
	; close the pipe with write /eof to get the end of file
	write /eof
	for  read *x:0 quit:$zeof  if ""'=x use $p write $char(x) use p2
	set k=$zeof
	close p2
	use $p
	write "$zeof = ",k,!
	quit
