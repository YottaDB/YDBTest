	; [XXX] look for all [XXX] for notes on things that need to be modified
	;
	; create routines (upto maxlen) with multiple labels (upto maxlen).
	; then depending on the value of act, either:
	; act="labels":
	;	run them, and check to make sure $ZPOSITION is reported correctly
	; 	output goes to driverm.out and driverc.out (generally dirver*)
	;
	; act="ZSHOW S":
	;	run them in a chain (each label^rout calls the next one across all routines)
	;	check the output of ZSHOW "S"
	;
	; call as:
	; do ^labtest
	; after setting the proper "act"ion.
	;
	; it will first prepare necessary files (writefil), then execute them (exefil)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
labtest ;
 	; labtest(act) ; <- change to act being a parameter
	set act="labels"
	;set act="ZSHOW S"	; to test ZSHOW "S"
	if '$DATA(act) write "ERROR, define act",! quit
	if ""=act write "ERROR, define act to a valid value",! quit
	; Note all "act"ions this routine recognizes:
	; act="labels"
	; act="ZSHOW S"
	; ...
	;
	set maxlen=31	; this is the final setting for longnames
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	do init		; initialize some variables to be used
	do writefil	; write all files involved
	do exefil	; execute files
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init	;
	;;;; define act in the calling routine
	set unix=$zv'["VMS"
	set driver="driver"
	set drvmfn=driver_".m"
	set drvcfn=driver_".csh"
	set drvzbfn=driver_"zb.m"
	set outfilem=driver_"m.out"
	set drvlabs=driver_"labels.m"
	set drvlabzb=driver_"labelszb.m"
	do init^lotsvar
	set rx=""
	set jj=$J(" ",maxlen+1)
	set counter=0	; verification of how many labels were called
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writefil ; will write the files involved
	write "##BEGIN labtest.m",!
	open drvmfn:(NEWVERSION)
	use drvmfn
	write " WRITE ""##BEGIN driver.m"",!",!
	open drvcfn:(NEWVERSION)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if "labels"=act do initlab	; since "labels" has more tests, it initializes more files
	for ri=1:1:maxlen do onevar^lotsvar(ri,1) set rx=strnosub do writerout
	for ri=1:1:maxlen-1 do onevar^lotsvar(ri,1) set rx="_"_strnosub do writerout
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; test DO label
	use drvmfn
	write " ;-----------------------",!
	set rxfn=drvlabs
	set rx=driver ; it's actually driver, but we don't want it printed explicitly in the DO calls this round.
	set rl=$LENGTH(driver)
	open rxfn:(NEWVERSION)
	use rxfn
	write " ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;",! ; seperator
	do w1riterout
	close rxfn
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if "labels"=act  do
	. use drvmfn
	. write " IF ",counter,"'=^COUNTER  DO",!
	. write " . WRITE ""LABTEST-E-ERROR counter does not match what it was supposed to be"",!",!
	. write " . WRITE ""The counter was supposed to be ",counter,", but is "",^COUNTER,!",!
	. write " ELSE  WRITE ""##PASS counter check."",!",!
	. write " WRITE ""##END ",drvmfn,""",!",!
	. write " QUIT",!
	. use drvcfn
	. ; since mumps -run takes so much more time, not all are run, so no counter check
	. write "echo ""##END ",drvcfn,"""",!
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; now append drvlabs to driver.m
	do append(drvmfn,drvlabs)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if "labels"=act do postlab
	if "ZSHOW S"=act do postzs
	; done preparing files
	close drvmfn
	close drvcfn
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
exefil	; now execute
	use $PRINCIPAL
	write "direct mode...",!
	write " (the output is in ",outfilem,")",!
	open outfilem:(NEWVERSION)
	use outfilem
	do ^driver
	use outfilem:(REWIND)
	do check(outfilem)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if "labels"=act  do
	. use $PRINCIPAL write "mumps -run label^routine...",!
	. set outfilec="driverc.out"
	. if unix  do
	.. zsystem "chmod +x "_drvcfn_"; rm *.o; "_drvcfn_" >&! "_outfilec
	.. open outfilec
	.. do check(outfilec)
	. else  do
	.. ; cannot run mumps -run lab^rout on vms, so simply remove the script
	.. zsystem "delete "_drvcfn_";*"
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	use $PRINCIPAL
	write "##END labtest.m",!
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check(outfile)	;
	; check the output file outfile for any errors (-E-).
	for i=1:1 use outfile read line quit:$ZEOF  do
	. USE $PRINCIPAL
	. if $FIND(line,"-E-") use $PRINCIPAL write "LABTEST-E-ERROR errors reported in ",outfile,". Check the line:",!,line,!
	use $PRINCIPAL
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writerout ;
	; writes one routine
	; let's first check if the requested
	if $DATA(routines(rx)) use $PRINCIPAL write "TEST-F-TSSERT, this routine cannot handle creating a routine a second time (because of the counter)",! halt
	set routines(rx)=1	;to denote we've processed this routine name
	set rxfn=rx_".m"
	set undl=$FIND(rx,"_") if undl set $EXTRACT(rx,undl-1,undl-1)="%" ; from now on, we want % instead of _
	set rl=$LENGTH(rx)
	open rxfn:(NEWVERSION)
w1riterout ;
	; write different types of labels in each routine
	set labname=""
	for ll=0:6:maxlen-1  do
	. do onevar^lotsvar(ll,1)	; labels of the form xxx (xxx len: [1,maxlen-1])
	. set labname=strnosub
	. if '((""=strnosub)&("driver"=rx)) do writelab
	. set labname="%"_strnosub	; labels of the form %xxx (xxx len: [1,maxlen-1])
	. do writelab
	for x=1:2:10  do
	. do onevar^lotsvar(maxlen,1)	; some labels of length maxlen
	. set labname=strnosub
	. do writelab
	close rxfn
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writelab ;
	; depending on the value of act, will write all output related to the
	; label/routine defined by labname/rx.
	; ZSHOW "S" testing
	if "ZSHOW S"=act  do
	. ; ZSHOW "S" testing
	. do writelb2
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if "labels"=act  do
	. ; basic labels testing ($ZPOSITION)
	. do writelb1
	. ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	. ; [XXX] if wrtcsh takes too long for maxlen=31, we might reduce the number of labels tested
	. ; as mumps -run using the below. Otherwise, remove this section (of comments).
	. ; do not perform the mumps -run test below for every label:
	. ; the counter is incremented for every label that was output to a file, so
	. ; we will print out drvcfn for every 100th label
	. ; since the drvcfn takes longer (as it does a mumps -direct and a mumps -run lab^rout for every label).
	. ;if '(counter#100) do wrtcsh	; since the mumps -run takes so much more time, let's not run it for every label
	. if unix do wrtcsh
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writelb2 ;
	; writes one label for ZSHOW "S" test
	use rxfn
	set lablen=$LENGTH(labname)
	write labname,$J(" ",maxlen+1-lablen),";",!
	if $DATA(prevlab) write jj,"DO ",prevlab,!
	else  do
	. write jj,"WRITE ""Now at the bottom, will do a ZSHOW S..."",!",!
	. write jj,"ZSHOW ""S""",!
	. write jj,"WRITE ""Now at the bottom, will do a ZSHOW S into global ^ZSHOWSGLOBALVARIABLE..."",!",!
	. write jj,"ZSHOW ""S"":^ZSHOWSGLOBALVARIABLE",!
	set counter=counter+1
	if driver'=rx set prevlab=labname_"^"_rx
	else  set prevlab=labname
	write jj,"quit",!
	quit
writelb1 ;
	;writes one label for "labels" test
	use rxfn
	set lablen=$LENGTH(labname)
	write labname,$J(" ",maxlen+1-lablen),"WRITE $TEXT(@$ZPOS),!",!
	write jj,"SET zpos=$ZPOSITION",!
	set counter=counter+1
	write jj,"DO chklbl^labtest(",lablen,",",rl,",""",rx,""",",counter,") ; chklbl^labtest(lablen,rl,rx,counter)",!
	write jj,"QUIT",!
	use drvmfn
	set labelref=labname_"^"_rx
	write " ;",labelref,!
	write " SET ^LABELREF=""",labelref,"""",!
	if driver'=rx write " DO ",labelref,!
	else  write " DO ",labname,!
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wrtcsh	;
	; writes the csh driver driver.csh
	;  VMS does not support the direct mode to call a label^routine
	use drvcfn
	write "mumps -direct << EOF",!
	write "SET ^LABELREF=""",labelref,"""",!
	write "EOF",!
	write "mumps -run ",labname,"^",rx,!
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
initlab ; writes the pre-processing parts to the various files for act="labels" testing
	; such as the tcsh line into the csh file,
	; the test part of driverzb.m,
	;open drvzbfn:(NEWVERSION)
	;open drvlabzb:(NEWVERSION)
	use drvmfn write " SET ^COUNTER=0",!
	use drvcfn
	write "#!/usr/local/bin/tcsh",!
	write "mumps -direct << EOF",!
	write "SET ^COUNTER=0",!
	write "EOF",!
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
postzs	; post processing (extra files, etc.) for act="ZSHOW S"
	if "ZSHOW S"=act  do
	. use $PRINCIPAL write "will test do ",prevlab," ...",!
	. use drvmfn
	. write " DO ",prevlab,!
	. write "checkstack ;",!
	. write " WRITE ""Will now analyze the ^ZSHOWSGLOBALVARIABLE global..."",!",!
	. write " SET x=""^ZSHOWSGLOBALVARIABLE""",!
	. write " FOR  SET x=$QUERY(@x) QUIT:x=""""  SET prevx=x",!
	. write " SET actcount=$PIECE($PIECE(prevx,"","",2),"")"",1)",!
	. write " ZWRITE ^ZSHOWSGLOBALVARIABLE",!
	. write " WRITE ""actual stack level was: "",actcount,!",!
	. set exp=counter+2 ; 2 levels extra
	. write " WRITE ""expected stack level was: ",exp,""",!",!
	. write " IF ",exp,"'=actcount  WRITE ""LABTEST-E-STACK stack level incorrect at "",$ZPOSITION,!",!
	. write " QUIT",!
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
postlab ; post processing (extra files, etc.) for act="labels"
	if "labels"=act  do
	. ;
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
append(f1,f2)	; append f2 to f1
	open f2:(READONLY:REWIND)
	for i=1:1 use f2 read line quit:$ZEOF  do
	. use f1
	. write line,!
	quit
	;;;;;;;;;;;;;;;
chklbl(lablen,rl,rx,counter)	;
	write "labelname is supposed to be ",lablen," characters",!
	write "routinename is supposed to be ",rl," characters",!
	write "$ZPOSITION:",zpos,!
	; rlabname is the labelname that was passed in through ^LABELREF, i.e. what it is supposed to be, labname is what $ZPOSITION reports, i.e. the actual (ditto for routname)
	set plussign=$FIND(zpos,"+")-1,uparrow=$FIND(zpos,"^",plussign)-1,labname=$EXTRACT(zpos,1,plussign-1),routname=$EXTRACT(zpos,uparrow+1,$LENGTH(zpos))
	set uparrow=$FIND(^LABELREF,"^")-1,rlabname=$EXTRACT(^LABELREF,1,uparrow-1),rroutname=$EXTRACT(^LABELREF,uparrow+1,$LENGTH(^LABELREF))
	if lablen'=$LENGTH(labname) write "LABTEST-E-ERROR incorrect label length at ",$ZPOSITION,!
	if rl'=$LENGTH(routname) write "LABTEST-E-ERROR incorrect routinename length at ",$ZPOSITION,!
	if labname'=labname write "LABTEST-E-ERROR incorrect label at ",$ZPOSITION,!
	set unix=$zv'["VMS"
	if unix set rxx=rx
	else  set rxx=$$FUNC^%UCASE(rx),rroutname=$$FUNC^%UCASE(rroutname)
	if rxx'=routname write "LABTEST-E-ERROR incorrect routinename at ",$ZPOSITION,!
	if labname'=rlabname write "LABTEST-E-ERROR actual label name (",labname,") does not match the label name called (",rlabname,") at ",$ZPOSITION,!
	if routname'=rroutname write "LABTEST-E-ERROR actual routine name (",routname,") does not match the routine name called (",rroutname,") at ",$ZPOSITION,!
	set ^COUNTER=^COUNTER+1
	write "counter points to ",counter," calls",!
	if counter'=^COUNTER write "LABTEST-E-ERROR Counter incorrect: expecting,",counter,", seen:",^COUNTER,!
	zwrite ^COUNTER
	write "----------------------------------------------------------------------",!
	quit
	;;;;;;;;;;;;;
