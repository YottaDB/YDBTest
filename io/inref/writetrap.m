WRITETRAP
	set p="test"
	set e="e1"
	set $ztrap="goto WRITEERR"
	open p:(comm="cat":stderr=e)::"pipe"
	use p
	read x:0
	use $p
	write x,!
	use e
	write "1",!
	quit
EOF	use $p
	write !,"eof"
	quit 
WRITEERR
	set a=$device
	set b=$za
	use $p
	write !,"write error",!!
	write "$zstatus = ",$zstatus,!
	write "$device = ",a,!
	write "$za = ",b,!
	close p
	quit 
BADOPEN	
	use $p
	write !,"badopen error"
	quit
