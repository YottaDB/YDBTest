testutf3:
	set p="test"
	open p:(comm="cat -u")::"pipe"
	use p
	if 1=$zcmdline do ^u50
	else  if 2=$zcmdline do ^u1000
	read x
	set d=$device set t=$test set za=$za set zeof=$zeof
	use $p
	write "device= ",d," test= ",t," za= ",za," zeof= ",zeof,!
	write "length = ",$l(x),!
	write x,!
	close p
	quit
