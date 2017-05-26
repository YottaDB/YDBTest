concurr
	;
init(initrtn,instance)
	set ^instance=instance
	do @initrtn
	do initcust^initdat(^prime)
	quit
run(times)
	set iterate=times
	do ^stress(1,5,10)
	quit
verify
	write "Application Level Verification Starts...",!
	for jobno=1,6,7,8,9,10  for veriter=1:1:12 do ^randfill("ver",1,veriter)
	write "Application Level Verification Ends.",!
	quit
