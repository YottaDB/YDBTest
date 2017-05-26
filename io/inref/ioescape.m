ioescape
	; use $io:(escape) to test pipe child file descriptor behavior
	use $io:(escape)
	; make sure $io is a TERMINAL
	zshow "d":savedev
	if ($find(savedev("D",1),"TERMINAL")) w "$io is a TERMINAL",!
	set a="test"
	set e="e1"
	open a:(comm="./echoback":stderr=e)::"pipe"
	zshow "d":savedev2
	; just show the pipe device
	write savedev2("D",2),!
	close a
	quit
