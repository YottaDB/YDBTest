compute(run);
	; Calls findhost.m
	; Calls spdata.m
	;
 	set $ZT="g ERROR^compute"                 
	set ^run=run
	set hname=$$^findhost(1)
	do image^spdata
 	do speed^srvconf(hname)
	set fname=^hostname(hname)_".m"
	write !,"Please check ",fname," for RefSpeed",!
	open fname:new
	USE fname
	write ^hostname(hname),";",!
	;
	write "        ;Data Collected on ",$ZDate($Horolog,"DD-MON-YEAR 24:60:SS"),! 
	set image=^image
	DO ^lblconf
	write label(accmeth,repl),";",!
	write "        ;",hname,";",$zv,";",image,";",accmeth,";",repl,!
	write "        set image=""",image,"""",!
	set totop=1
	set opname(1)="ZDSRTST1"
	do calc^compute(image,"ZDSRTST1","NOJNL","RANDOP",1)
	set totop=1
	set opname(1)="ZDSRTST2"
	do calc^compute(image,"ZDSRTST2","NOJNL","RANDOP",1)
	set opname(1)="SETOP"
        set opname(2)="READOP"
        set opname(3)="GETOP"
        set opname(4)="DATAOP"
        set opname(5)="ORDEROP"
        set opname(6)="ZPREVOP"
        set opname(7)="QUERYOP"
        set opname(8)="KILLOP"
	do calc^compute(image,"LCL","NOJNL","SEQOP",2)
	do calc^compute(image,"LCL","NOJNL","RANDOP",8)
gbl;
	;
	set opname(1)="SETOP"
        set opname(2)="READOP"
        set opname(3)="GETOP"
        set opname(4)="DATAOP"
        set opname(5)="ORDEROP"
        set opname(6)="ZPREVOP"
        set opname(7)="QUERYOP"
        set opname(8)="KILLOP"
	do calc^compute(image,"GBLS","NOJNL","SEQOP",2)
	do calc^compute(image,"GBLS","NOJNL","RANDOP",2)
	do calc^compute(image,"GBLREORG","NOJNL","RANDOP",2)
	do calc^compute(image,"GBLM","NOJNL","RANDOP",8)
tpba;
	set opname(1)="TPBA"
	do calc^compute(image,"TPBA","NOJNL","RANDOP",1)
	do calc^compute(image,"TPBA","JNL","RANDOP",1)
tpon;
	set opname(1)="TPON"
	do calc^compute(image,"TPON","JNL","RANDOP",1)
locki;
	set opname(1)="LOCKI"
	do calc^compute(image,"LOCKI","NOJNL","SEQOP",1)
	write "        quit",!
	close fname
	q
calc(image,type,jnlstr,order,opcnt)
	For i=1:1:opcnt DO
	.  set opname=opname(i)
	.  set cpusum=0.0
	.  set elpsum=0.0
	.  for run=1:1:^run DO
	.  .  set cpusum=cpusum+$GET(^speed(image,type,jnlstr,opname,order,"CPU",run))
	.  .  set elpsum=elpsum+$GET(^speed(image,type,jnlstr,opname,order,"ELP",run))
	.  set avgcpu=cpusum/^run
	.  set avgelp=elpsum/^run
	.  use fname
	.  write "        set ^RefSpeed(image,","""",type,""",""",jnlstr,""",""",opname,""",""",order,""",""CPU"")=",$J(avgcpu,0,2),!
	.  write "        set ^RefSpeed(image,","""",type,""",""",jnlstr,""",""",opname,""",""",order,""",""ELP"")=",$J(avgelp,0,2),!
	.  set cpusum=0.0
	.  set elpsum=0.0
	.  for run=1:1:^run DO
	.  .  set diffcpu=$GET(^speed(image,type,jnlstr,opname,order,"CPU",run))-avgcpu
	.  .  set diffcpu=diffcpu*diffcpu
	.  .  set diffelp=$GET(^speed(image,type,jnlstr,opname,order,"ELP",run))-avgelp
	.  .  set diffelp=diffelp*diffelp
	.  .  set cpusum=cpusum+diffcpu
	.  .  set elpsum=elpsum+diffelp
	.  if ^run>1 set nm1=^run-1
	.  else  set nm1=1
	.  set devcpu=$$FUNC^%SQROOT(cpusum/nm1)
	.  set develp=$$FUNC^%SQROOT(elpsum/nm1)
	.  write "        set ^Sigma(image,","""",type,""",""",jnlstr,""",""",opname,""",""",order,""",""CPU"")=",$J(devcpu,0,2),!
	.  write "        set ^Sigma(image,","""",type,""",""",jnlstr,""",""",opname,""",""",order,""",""ELP"")=",$J(develp,0,2),!
	q
ERROR   set $ZT=""
	USE 0
        ZSHOW "*"
        ZM +$ZS
        Q       
