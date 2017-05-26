u1000
	; write 1000 utf-8 characters to the current device
	for j=1:1:20 do
	. for i=1:1:50 do
	.. set a=1350+i
	.. write $c(a)
	. write "Z"
      	write !
	quit
