INETD	s dev=$device,dollarkey=$key
	use $p:delim=$char(13,10)
	zshow "D"
	read "say something :",!,a
	zwrite
	s file="rms.txt" o file:new
	u file
	zwrite
	close file
	w "wrote file rms.txt",!
	zshow "D"
	w "the end",!
	q
