u10
	; write 10 utf-8 characters to the current device
	for i=1:1:10 do
	. set a=1350+i
	. write $c(a)
	write !
	quit
