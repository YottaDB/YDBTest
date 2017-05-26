unicodedir;
	write !,"Start of unicodedir",!
	write "$zcmdline=",$zcmdline,!
	write "$zdir=",$zdir,!
	write "$zgbldir=",$zgbldir,!
	write "$zsearch=",$zsearch("*.o"),!
	write "$zparse=",$zparse("*.o"),!
	set objfiles=$zcmdline_"/*.o"
	write "$zsearch=",$zsearch(objfiles),!
	write "$zparse=",$zparse(objfiles),!
	write "unicodedir finished",!
	quit
