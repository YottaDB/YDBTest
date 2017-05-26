gtm6502
	; Since keysize is randomly selected and it may be as small as 3, use ^f as the name of the global that counts failures
	set numwrites=+$zcmdline
	set ^f=0
	set $ztrap="set ^f=^f+1 write ""i="",i,"" ""  goto incrtrap^incrtrap"
	for i=1:1:numwrites  do
	.       set ^a($j(1,i))=1
	quit

check
	set cmdline=$zcmdline
	set maxkey=+$piece(cmdline," ",1)
	set numwrites=+$piece(cmdline," ",2)
	; if maxkey is less than 6 then there will be numwrites failures and no expected successes	  
	; else expect maxkey-5 passes
	if 6'>maxkey set PassesExpected=maxkey-5
	else  set PassesExpected=0
	set passes=0
	if 0'=$data(^a) for passes=0:1 set sub=$order(^a($get(sub)))  quit:sub=""
	if PassesExpected'=passes write "TEST-F-FAIL ",PassesExpected,"'=",passes,!
	if (numwrites-^f)'=passes write "TEST-F-FAIL ",^f,"+",passes,"is wrong",!
	quit
