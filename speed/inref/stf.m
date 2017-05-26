stf	; Concurrent TP transactions 
	;
	;
	set $ZT="g ERROR^stf"
	set jnlstr=^jnlstr
	set unix=^unix
	;
	set fnname="stf"
	set output=fnname_".mjo0",error=fnname_".mje0"
        Open output:newversion,error:newversion
        Use output
        W "PID: ",$J,!
        Close output
	;
	set ^tptype=^typestr
	set ^opname(1)=^tptype
	set jobcnt=^jobcnt
	set size=^size
	set repeat=^repeat
	;
	; Initialize Cust database 
	write "do initcust^spdata",!  do initcust^spdata
	;
	set ^totdata=^jobcnt*^size*^repeat
	write "Total TP transactions count =",^totdata,!    
	;
	set mainbeg=$h
	set jmaxwait=3600*6	
	;
	do ^job("stfjob^stf",jobcnt,"""""")
	;
	set mainend=$h
        set ^elaptime(^image,^typestr,^jnlstr,^typestr,^order,"PARENT",^run)=$$^difftime(mainend,mainbeg)     
	set tpcnt=0
	for jobno=1:1:jobcnt set tpcnt=tpcnt+^tpcnt(jobno)
	write "tpcnt=",tpcnt,!
	if tpcnt'=^totdata write "TEST-E-FAILED tpcnt'=^totdata",! zwr ^tpcnt,^totdata
	write !,"All job has finised now.",!
	;
	q


stfjob;
	new loop,tpcnt
	set tpcnt=0
	set $ZT="g ERROR^stf"
	W "PID: ",$J,!
	set tcflag="TPC"
	set ctop=^ctop
	set size=^size
	set prime=^prime
	set repeat=^repeat
	set jobcnt=^jobcnt
	set jobno=jobindex
	if ^tptype="TPON" set tptype="ONLINE"
	else  set tptype="BA"
	if jobno=4  set tcflag="TPR"
	set pid(jobno)=$J
	set ^pid=$j
	WRITE "TYPE:",tcflag,!
	set ^opname(1)=^tptype
	;
        set et1=$H
        set t1=$ZGETJPI(0,"CPUTIM")
	new loop,rep,ndx,root
	for rep=1:1:repeat DO
	.  set root=^root(1+jobno#10)
	.  set ndx=root
	.  for loop=1:1:size DO
	.  .  d mainop^stf(ndx,loop,size)
	.  .  set ndx=ndx*root#prime
	set t2=$ZGETJPI(0,"CPUTIM")
        set et2=$H
        do RESULT^stf(t1,t2,et1,et2)
	set ^tpcnt(jobno)=tpcnt
	w "Successful",!
	q

mainop(ndx,loop,size)
	new A,%A,obj,tr,cndx,confl,curcust
	set tr(49)="123456|3.14|DW|49|49|AAAAAAAAAAAAA"
	set tr(50)="123456|3.14|DW|50|50|BBBBBBB"
	set tr(51)="123456|3.14|DW|51|51|CCCCCCCCC"
	set tr(52)="123456|3.14|DW|52|52|DDD"
	set cndx=1+(ndx#ctop)
	set curcust=$GET(^cust(cndx))
	;
	set A(49,ndx)=$piece(curcust,"|",2)
	set A(50,ndx)=$piece(curcust,"|",3)
	set %A(51,ndx)=$piece(curcust,"|",5)
	set %A(52,ndx)=$piece(curcust,"|",2)
	;
	if tcflag'="NTP" TSTART (%A,A,tpcnt,confl):(serial:transaction=tptype)
	d lclupd^stf(.A,.%A,.tr) 
	d gblupd^stf(.A,.%A,.obj) 
	set confl(jobno,$TRESTART)=1
	set tpcnt=tpcnt+1
	if tcflag="TPR" IF $TLEVEL TROLLBACK
	if tcflag="TPC" IF $TLEVEL TCOMMIT
	;
	if tcflag="TPR" do tprdat^stf(jobno,ndx,.A,.%A,tptype)
	for cnt=1:1:10 do
	. if $data(confl(jobno,cnt)) set ^confl(jobno,cnt)=$GET(^confl(jobno,cnt))+1
	q

lclupd(A,%A,tr)	;
	set A(49,ndx)=A(49,ndx)-$piece(tr(49),"|",5)
	set A(50,ndx)=A(50,ndx)-$piece(tr(50),"|",5)
	set %A(51,ndx)=%A(51,ndx)-$piece(tr(51),"|",4)
	set %A(52,ndx)=%A(52,ndx)-$piece(tr(52),"|",4)
	q

gblupd(A,%A,obj)	;
	new nextcust,tmpi
	set tmpi=1+((cndx+1)#ctop)
	set nextcust=$GET(^cust(cndx))
	if (jobno=1)!(jobno>6) do
	. set ^afill(ndx,curcust,jobno)=A(49,ndx)
	. set ^bfill(ndx,curcust,jobno)=A(49,ndx)
	. set ^dfill(ndx,curcust,jobno)=A(49,ndx)
	. set ^efill(ndx,curcust,jobno)=A(49,ndx)
	. set ^ffill(ndx,curcust,jobno)=A(49,ndx)
	. set ^gfill(ndx,curcust,jobno)=A(49,ndx)
	if jobno=2 do
	. set ^afill(ndx,curcust,jobno)=A(50,ndx)
	. set ^bfill(ndx,curcust,jobno)=A(50,ndx)
	. set ^dfill(ndx,curcust,jobno)=A(50,ndx)
	. set ^efill(ndx,curcust,jobno)=A(50,ndx)
	. set ^ffill(ndx,curcust,jobno)=A(50,ndx)
	. set ^gfill(ndx,curcust,jobno)=A(50,ndx)
	if jobno=3 do
	. set ^afill(ndx,nextcust,jobno)=%A(51,ndx)
	. set ^bfill(ndx,nextcust,jobno)=%A(51,ndx)
	. set ^dfill(ndx,nextcust,jobno)=%A(51,ndx)
	. set ^efill(ndx,nextcust,jobno)=%A(51,ndx)
	. set ^ffill(ndx,nextcust,jobno)=%A(51,ndx)
	. set ^gfill(ndx,nextcust,jobno)=%A(51,ndx)
	if jobno=4 do
	. set ^afill(ndx,nextcust,jobno)=%A(52,ndx)
	. set ^bfill(ndx,nextcust,jobno)=%A(52,ndx)
	. set ^dfill(ndx,nextcust,jobno)=%A(52,ndx)
	. set ^efill(ndx,nextcust,jobno)=%A(52,ndx)
	. set ^ffill(ndx,nextcust,jobno)=%A(52,ndx)
	. set ^gfill(ndx,nextcust,jobno)=%A(52,ndx)
	if jobno=5 do
	. set ^afill(ndx,curcust,jobno)=A(49,ndx)
	. set ^bfill(ndx,curcust,jobno)=A(49,ndx)
	. set ^dfill(ndx,curcust,jobno)=A(49,ndx)
	. set ^hfill(jobno,loop,tr(51))=curcust
	. set ^hfill(jobno,loop,tr(52))=curcust
	if jobno=6 do
	. set ^afill(ndx,nextcust,jobno)=%A(51,ndx)
	. set ^bfill(ndx,nextcust,jobno)=%A(51,ndx)
	. set ^dfill(ndx,nextcust,jobno)=%A(51,ndx)
	. set ^hfill(jobno,ndx,tr(51))=nextcust
	. set ^hfill(jobno,ndx,tr(52))=nextcust
	; Concurrency conflict causes indeterminate number of restarts. So command trestart is used
	; We want fixed number of restarts so that speed data do not vary a lot.
	if loop#64=0 if $trestart<1 trestart
	if loop#128=0 if $trestart<2 trestart
	q
	 
tprdat(jobno,ndx,A,%A,tptype)	;
	TSTART ():(serial:transaction=tptype)
	set ^tprdat(jobno,ndx,49)=A(49,ndx)
	set ^tprdat(jobno,ndx,50)=A(50,ndx)
	set ^tprdat(jobno,ndx,51)=%A(51,ndx)
	set ^tprdat(jobno,ndx,52)=%A(52,ndx)
	TCOMMIT
	q

NULLOP
	set et3=$H
        set t3=$ZGETJPI(0,"CPUTIM")
	new loop,rep,ndx,root
	for rep=1:1:repeat DO
	.  set root=^root(1+jobno#10)
	.  set ndx=root
	.  for loop=1:1:size DO
	.  .  set ndx=ndx*root#prime
	set t4=$ZGETJPI(0,"CPUTIM")
	set et4=$H
	quit

RESULT(t1,t2,et1,et2)
        do NULLOP^stf
	set opname=^typestr
	set cputime=t2-t1
	set cpuovrhd=t4-t3
	set elptime=$$^difftime(et2,et1)
	set elpovrhd=$$^difftime(et4,et3)
	if (cpuovrhd>(cputime))  W "TEST-E-SPEED_TEST: cpu time overhead is more than cpu time!!!  "," t1=",t1," t2=",t2," t3=",t3," t4=",t4,!  
	if (elpovrhd>(elptime))  W "TEST-E-SPEED_TEST: elapse time overhead is more than elapse time!!!  "," et1=",et1," et2=",et2," et3=",et3," et4=",et4,!  
	if (elptime<1) set elptime=1
	if (cputime<1) SET cputime=1
        set ^cputime(^image,^typestr,^jnlstr,opname,^order,jobno,^run)=cputime-cpuovrhd
        set ^elaptime(^image,^typestr,^jnlstr,opname,^order,jobno,^run)=elptime-elpovrhd
        set ^cpuovrhd(^image,^typestr,^jnlstr,opname,^order,jobno,^run)=$j((100.0*(cpuovrhd)/(cputime)),7,2)
        set ^elpovrhd(^image,^typestr,^jnlstr,opname,^order,jobno,^run)=$j((100.0*(elpovrhd)/(elptime)),7,2)
        q

ERROR 	set $ZT=""
	if $tlevel trollback
	ZSHOW "*" 
	q
