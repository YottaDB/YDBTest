printtim;
	set $ZT="g ERROR^printtim"
	set jobcnt=^jobcnt
	set typestr=^typestr
	set jnlstr=^jnlstr
	set order=^order
	set machine=$$^findhost(1)
	set refimage="PRO"
	set fn=^hostname(machine)
	do ^lblconf	
	do @label(accmeth,repl)^@fn
	set totop=^totop
	set repeat=^repeat
	set numproc=+$ZTRNLNM("numproc")
	if numproc=0 set numproc=1
	W "Number of Processor in this machine:",numproc,!
	for optype=1:1:totop  D
	.  set opname=^opname(optype)
	.  set REFCPU=+$GET(^RefSpeed(refimage,typestr,jnlstr,opname,order,"CPU"))
	.  set REFELP=+$GET(^RefSpeed(refimage,typestr,jnlstr,opname,order,"ELP"))
	.  set SIGCPU=+$GET(^Sigma(refimage,typestr,jnlstr,opname,order,"CPU"))
	.  set SIGELP=+$GET(^Sigma(refimage,typestr,jnlstr,opname,order,"ELP"))
	.  ; Following to avoid devide by zero
	.  if REFCPU=0 set REFCPU=1.0  W "TEST-W REFCPU is 0, using 1.0",!
	.  if REFELP=0 set REFELP=1.0  W "TEST-W REFELP is 0, using 1.0",!
	.  set totcpu=0.0
	.  set totelap=0.0
	.  set parelap=$GET(^elaptime(^image,^typestr,^jnlstr,opname,^order,"PARENT",^run))
	.  for i=1:1:jobcnt  do
	.  . ; Note: 100th of a second is measured
	.  . set totcpu=totcpu+^cputime(^image,^typestr,^jnlstr,opname,^order,i,^run)
	.  . set totelap=totelap+^elaptime(^image,^typestr,^jnlstr,opname,^order,i,^run)
	.  IF totcpu<1 Write !,"TEST-W-CPU Time cannot be <= 0. TEST FAILED.",!  set totcpu=1
	.  IF totelap<1 Write !,"TEST-W-ELAPSED time should be a second at least.",!  set totelap=1
	.  set cpuavg=totcpu/jobcnt
	.  set elapavg=totelap/jobcnt
	.  set CPUSPD=(^totdata*100.0)/totcpu	; Operations/CPU Sec (100th of a second is unit)
	.  set ELPSPD=(^totdata)/elapavg		; Operations/Elapsed Wall Clock Sec
	.  set pctcpu=100.0*CPUSPD/REFCPU
	.  set pctelp=100.0*ELPSPD/REFELP
	.  IF REFCPU=1.0 set pctcpu=0.0
	.  IF REFELP=1.0 set pctelp=0.0
	.  Write !,"SPEED_TEST:",$j(typestr,8),":",$j(opname,8),":",$j(order,6),":",$j(jnlstr,6)
	.  Write ":Ops/CPU_sec:",$JUSTIFY(CPUSPD,7,0),":",$JUSTIFY(pctcpu,5,1)," %"
	.  Write ":Ops/Elapsed_sec:",$JUSTIFY(ELPSPD,7,0),":",$JUSTIFY(pctelp,5,1)," %"
	.  Write ":CPU UTILIZED:",$JUSTIFY(totcpu/(numproc*elapavg),5,1)," %"
	.  set pass=1
	.  If (REFCPU=1.0)!(^cputoler*(REFCPU-(2*SIGCPU))>CPUSPD) set pass=0
	.  If (REFCPU=1.0)!(^elptoler*(REFELP-(2*SIGELP))>ELPSPD) set pass=0
	.  IF pass=1 Write ":PASS",!
	.  Else  Write ":FAIL",!
	.  set ^speed(^image,typestr,jnlstr,opname,order,"CPU",^run)=CPUSPD
	.  set ^speed(^image,typestr,jnlstr,opname,order,"ELP",^run)=ELPSPD
	.  zwrite parelap,elapavg
	zwrite ^elaptime,^cputime,^cpuovrhd,^elpovrhd
	set (confl(1),confl(2),confl(3))=0
	if typestr["TP" do
	.  for jobno=1:1:jobcnt  DO
	.  .  set confl(1)=confl(1)+$GET(^confl(jobno,1))
	.  .  set confl(2)=confl(2)+$GET(^confl(jobno,2))
	.  .  set confl(3)=confl(3)+$GET(^confl(jobno,3))
	.  set ^confl(^image,typestr,jnlstr,opname,order,"REST",1)=confl(1) 
	.  set ^confl(^image,typestr,jnlstr,opname,order,"REST",2)=confl(2)
	.  set ^confl(^image,typestr,jnlstr,opname,order,"REST",3)=confl(3)
	.  zwrite ^confl
	zwrite ^sizes(^typestr,^order,^jnlstr)
	Write "SPEED_TEST:",^typestr,":Ends at  :",$ZDate($Horolog,"24:60:SS"),! 
	Quit

ERROR   set $ZT=""
	ZSHOW "*"
        ZM +$ZS
	Q
