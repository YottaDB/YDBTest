zbmain;
basic;
	write $zpos,"$zlevel=",$zlevel,!
        new Avariable,AA,expr,mindex,cmd,varname
	set ^callcnt=$get(^callcnt)+1
	set zbmaxloop=10 
	set AA="ZBREAKAA" set @AA="Avariable"
	set expr="ZBMAIN=22" set @expr
	new cmd
	for mindex=1:1:zbmaxloop  do
	. set cmd="set %zbmva"_mindex_"=mindex"  xecute cmd
	for mindex=1:1:zbmaxloop  do
	. set varname="%zbreak"_mindex
	. set @varname=mindex
	. set zbreak(mindex)=mindex
	if $get(^setrout1)=0 set global=0 do set^lotsvar  set ^setrout1=$get(^setrout1)+1
	if $get(^setrout2)=0 do in1^lfill("set",5,1)  set ^setrout2=$get(^setrout2)+1
	set @"zbendofbasic"=1
stress;
	new cmdcnt
	set ^myvar=$get(^myvar)+1
	if ($data(^caller))=0 set ^caller=100
	set ^pid=$j
	for cmdcnt=1:1:5 do
	. set command(cmdcnt)="set "_$C(64+cmdcnt)_"var=$j"
	. xecute command(cmdcnt)
	tstart ():(serial:t="BA")
	set ^tstcnt=$get(^tstcnt)+1
	set ^tailcnt(^myvar,^caller)=$get(^tailcnt(^myvar,^caller))+1
	tc
	kill myvar
	set myvar(1)=Avar
	set myvar(2)=Bvar
	set myvar(3)=Cvar
	tstart (myvar):(serial:t="BA")
	set myvar(4)=Dvar
	set myvar(5)=Evar
	merge mergvar=myvar
	zkill myvar(1)
	kill myvar(2)
	kill myvar
	if $trestart=0 trestart
	if $tlevel trollback
	quit
verify;
	write "Verify",!
	do ^examine($get(zbmaxloop),10,"zbmaxloop")
	for mindex=1:1:zbmaxloop do
	. set vname="%zbmva"_mindex  do ^examine($get(@vname),mindex,vname)
	. set vname="%zbreak"_mindex  do ^examine($get(@vname),mindex,vname)
	. do ^examine($get(zbreak(mindex)),mindex,"zbreak()")
	do ^examine($get(ZBMAIN),22,"ZBMAIN")
	do ^examine($get(ZBREAKAA),"Avariable","ZBREAKAA")
	do ^examine($get(zbendofbasic),1,"zbendofbasic")
	for cmdcnt=1:1:5 do
	. set varname=$C(64+cmdcnt)_"var"  do ^examine($get(@varname),^pid,varname)
	. do ^examine($get(mergvar(cmdcnt)),^pid,"mergvar()")
	if $data(^setrout1) set global=0 do ver^lotsvar  
	if $data(^setrout2) do in1^lfill("ver",5,1) 
	write "Verify Done",!
	quit
forcerr;
	new $ZT
	set $ZT="set $ZT="""" goto myerr^zbmain"
	write "ZT=",$ZT,!
	write "Will force an error",!
	set forcerr1="forcerr1 value was set"
	set forcerr2=junk
	quit
myerr;
	write "After forcerr caused error : Show the break points and stack:"  zshow "BS"
	write "$zstatus=",$zstatus,!
	if $data(forcerr1) write "zwrite forcerr1",!  zwrite forcerr1
	if $data(zberr) write "zwrite zberr",!  zwrite zberr
	write "zhsow ""B""",!  zshow "B"
	if ($data(myerrcnt))=0 set myerrcnt=0
	else   set myerrcnt=myerrcnt+1
	set zbjunk(myerrcnt)=0
	write "Exiting myerr",!
	quit
