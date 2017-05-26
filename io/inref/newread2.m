newread
	set cnt=0
	set j=1000
	set a="test"
	set e="e1"
	open a:(comm="tr e j | ./echoback":stderr=e)::"pipe"
	use e
	read x:1
	if $find(x,"echoback:") quit
	for i=1:1:j do
	. use a
 	. write i,":abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz",!
	. read x:0
	. set d=$device
	. if ""'=x use $p write x,!,d,! set cnt=cnt+1
	. use e
	. read y:0
	. set k=$device
	. if ""'=y use $p write y,!,k,! set cnt=cnt+1
	use $p
	write "end phase 1",!
	use a
	write /eof
	for  read x quit:$zeof  use $p write x,! set cnt=cnt+1 use e read x quit:$zeof  use $p write x,! set cnt=cnt+1 use a
	if (e'=$io)&(cnt'=j) do
	. use e 
	. read y:0
	. if ""'=y use $p write y,!
	use $p
	write "done",!
	close a
	quit
