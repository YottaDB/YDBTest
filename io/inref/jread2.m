jread
	set bfile="bigfile"
	open bfile:newver
	use bfile
	for i=1:1:4000 do
	. write "abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz",!
	close bfile
	set a="test"
	open a:(comm="cat bigfile | tr e 8 | nl")::"pipe"
	use a:exception="G EOF1"
  	write /eof
	; have to use exception handler for r:0 on sun and hpux-ia64
	for  read x:0 if ""'=x use $p write x,! use a
EOF1
	set k=$zeof
	close a
	use $p
	write "$zeof = ",k,!
	quit
