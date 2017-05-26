; Verify zwrite works when a spanning node is a child of a non-spanning node.
; This is called from basic.csh

zwrite
	set ^nsgbl="root"
	set ^nsgbl(1)=1
	set ^nsgbl(1,1)="BEGIN"_$justify(" ",8900)_"END"
	set ^nsgbl(1,1,1)=2
	zkill ^nsgbl(1,1)
	write "Verify that zwrite prints  ^nsgbl(1) and ^nsgbl(1,1,1)",!
	zwrite ^nsgbl
	s ^y=$justify("value",2000)
	s ^y(1)="findme!"
	zwrite ^y 
	quit
