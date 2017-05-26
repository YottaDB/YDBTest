testutf2:
	set p="test"
	open p:(comm="./strip_cr")::"pipe"
	use p
	if 1=$zcmdline do ^u50
	else  if 2=$zcmdline do ^u1000
	for  read x:0 q:x'=""
	set d=$device set t=$test set za=$za set zeof=$zeof
	use $p
	write "device= ",d," test= ",t," za= ",za," zeof= ",zeof,!
	write "length = ",$l(x),!
	write x,!
	close p
	quit
