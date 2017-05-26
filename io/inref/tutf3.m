tutf3
	set p="test"
	if 1=$zcmdline o p:(comm="cat -u")::"pipe"
	else  if 2=$zcmdline o p:(comm="cat -u":fixed:recordsize=100)::"pipe"
	else  if 3=$zcmdline o p:(comm="cat -u":fixed:recordsize=70)::"pipe"
	else  if 4=$zcmdline o p:(comm="cat -u":fixed:recordsize=70:nowrap)::"pipe"
	zshow "d"
	u p
	for j=1:1:50 d
	. u p
	. do ^u50
	. for  r x:0 q:x'=""
	. u $p w j," - ",x,! u p
	if 3'>$zcmdline quit
	u p
	w /eof
	f  r x:0 q:$zeof
	set a=$zeof
 	u $p
	w "zeof = ",a,!
	c p
	quit
