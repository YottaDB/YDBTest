ureadstderr
	; make sure no problem reading from stderr in unicode
	use $p
	set f="in"
	open f:(comm="echoback":stderr="se")::"pipe"
	use f
	for k=1:1:200 w "k = "_k,!
	; close the input to echoback so we can detect eof for stdout and stderr
	write /eof
	for j=1:1 read x(j) quit:$zeof
	set j=j-1
	use "se"
	for m=1:1 read y(m) quit:$zeof
	set m=m-1
	use $p
	write "Number of lines read from stdout = ",j,!
	zwrite x(j)
	write "Number of lines read from stderr = ",m,!
	zwrite y(m)
	quit
