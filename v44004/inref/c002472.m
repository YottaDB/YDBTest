c002472(onoff,wait) ; test set noop optimization
	if '$DATA(onoff) set onoff="off"
	if '$DATA(wait) set wait=0
	write "do ^c002472(",onoff,",",wait,")...",!
	set unix=$ZVERSION'["VMS"
	if unix set opfile="options.csh"
	else  set opfile="options.com"
	open opfile:NEWVERSION
	use opfile
	if unix do
	. write "set onoff = ",onoff,!
	. write "set sleeptime = ",wait,!
	else  do
	. write "$ onoff :== ",onoff,!
	. write "$ sleeptime == ",wait,!
	close opfile
	use $PRINCIPAL
	do checksn(onoff)
	do sets(wait)
	do checksn(onoff)
	do chckdata
	quit
checksn(onoff) ;check GVDUPSETNOOP
	if '$DATA(onoff) set onoff="off"
	set errcnt=0
	set viewsn=$VIEW("GVDUPSETNOOP")
	write "$VIEW(""GVDUPSETNOOP""): ",viewsn,!
	if "on"=onoff,viewsn=0 set errcnt=1,exp=1
	if "off"=onoff,viewsn=1 set errcnt=1,exp=0
	if 'errcnt write "OK.",!
	else  write "TEST-E-FAIL, Was expecting ",exp,", actual: ",viewsn,!
	quit

sets(wait) ;;;;many sets
	if '$DATA(wait) set wait=0
	set ^z="some global in region DEFAULT"
	for loop=1:1:5 do
	. write "loop ",loop,"...",!
	. for i=1:1:5 do
	. . set ^ach(i)=i+loop view:loop=1 "epoch"
	. . set ^anoch(i)=1 view:loop=1 "epoch"
	. . set ^bnoch(i)=1 view:loop=1 "epoch"
	. . set ^anochlongglobalnamesworkfornoop(i)=1 view:loop=1 "epoch"
	. . set ^bnochlongglobalnamesworkfornoop(i)=1 view:loop=1 "epoch"
	. . set li=^z
	. . tstart ()
	. . set ^cch(i)=i+loop
	. . set ^cnoch(i)=1
	. . set ^cnochlongglobalnamesworkfornoop(i)=1
	. . set ^dnoch(i)=1
	. . set ^dnochlongglobalnamesworkfornoop(i)=1
	. . set li=^z
	. . tcommit
	. . ; the hang wait is necessary for synchronization of the PBLK's to be written
	. . ; without the hang all the updates will be made in one (or two) EPOCH durations, hence
	. . ; we will not be able to see the effects of the optimization
	. . ; however, with an epoch interval of 2 seconds, and a hang of 3 seconds, we ensure that
	. . ; each set will be in it's own epoch interval, and will/won't write the PBLK depending on
	. . ; whether the optimization is enabled or not.
	. . if wait hang wait
	quit
chckdata ;to check the data is correct
	; make sure this code is very similar to sets above.
	set errcnt=0
	set loop=5
	for i=1:1:5 do
	. do chck(^ach(i),i+loop)
	. do chck(^anoch(i),1)
	. do chck(^bnoch(i),1)
	. do chck(^anochlongglobalnamesworkfornoop(i),1)
	. do chck(^bnochlongglobalnamesworkfornoop(i),1)
	. do chck(li,^z)
	. do chck(^cch(i),i+loop)
	. do chck(^cnoch(i),1)
	. do chck(^cnochlongglobalnamesworkfornoop(i),1)
	. do chck(^dnoch(i),1)
	. do chck(^dnochlongglobalnamesworkfornoop(i),1)
	quit
chck(x,y) if x'=y write "TEST-E-FAIL, not equal: x: ",x,",y: ",y,!
