blockedwrite:
	; write output until pipe blocks.  When it traps, empty some of the lines and return
	; to process more
	set p1="test1"
	set a=0
	open p1:(shell="/bin/sh":command="cat -u")::"pipe"
	set $ztrap="goto cont1"
	for i=1:1:10000  do
	. use p1
	. set c=i_":abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz"  
	. write c,!
	. use $p write i,!
	use p1
  	write /eof
	for  read x quit:$zeof  use $p write x,! use p1
	close p1
	quit
cont1
	if a=0 set a=i/2
	set z=$za
	; use $device to make sure ztrap caused by blocked write to pipe
	set d=$device
	if "1,Resource temporarily unavailable"=d do
	. use $p
	. write "pipe full, i= ",i," $za = ",z,!
	. set i=i-1
	. use p1
	. for j=1:1:a  read x use $p write j,"-",x,! use p1
	quit
