testutf1:
	set p="test"
	set x=""
	open p:(comm="./strip_cr")::"pipe"
	use p
	if 1=$zcmdline do ^u50
	else  if 2=$zcmdline do ^u1000
	set timeout=5
	; try up to 3 times for data
	for i=1:1:3 quit:$length(x)  do
	. read x:timeout
	. set d=$device set t=$test set za=$za set zeof=$zeof
	. set timeout=2*timeout
	use $p
	write "device= ",d," test= ",t," za= ",za," zeof= ",zeof,!
	write "length = ",$length(x),!
	write x,!
	close p
	quit
