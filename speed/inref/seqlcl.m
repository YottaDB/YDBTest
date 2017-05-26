seqlcl; Speed test functions 
SETOP;  Sets 
	SET ^opname(1)="SETOP"
	SET et1=$H
        SET t1=$ZGETJPI(0,"CPUTIM")
        FOR rep=1:1:repeat DO
        .  FOR ndx=1:1:prime-1 D
	.  .  SET cndx=cust(1+(ndx#ctop))_ndx
	.  .  SET afill(jobno,ndx)=$piece(cndx,"|",2)
        .  .  SET bfill(ndx,cndx)=ndx/7
        .  .  SET dfill(jobno,cndx)=$extract(cndx,5,40)
        .  .  SET efill(jobno,rep,ndx)=$find(cndx,"a")
        .  .  SET ffill(cndx,ndx,3.14)=$C(0,1,65,97,128,155,255)
        .  .  SET gfill(rep,ndx)=$length(cndx)
        .  .  SET hfill(cndx,jobno)=$justify(999999999.99,15)
        SET t2=$ZGETJPI(0,"CPUTIM")
        SET et2=$H
	do RESULT^seqlcl(^opname(1),t1,t2,et1,et2)
	;ZWR afill,bfill,dfill,efill,ffill,gfill,hfill
	q
READOP; Reads
	SET ^opname(2)="READOP"
	SET et1=$H
        SET t1=$ZGETJPI(0,"CPUTIM")
        FOR rep=1:1:repeat DO
        .  FOR ndx=1:1:prime-1 D
	.  .  SET cndx=cust(1+(ndx#ctop))_ndx
	.  .  SET RES=afill(jobno,ndx)
        .  .  SET RES=bfill(ndx,cndx)
        .  .  SET RES=dfill(jobno,cndx)
        .  .  SET RES=efill(jobno,rep,ndx)
        .  .  SET RES=ffill(cndx,ndx,3.14)
        .  .  SET RES=gfill(rep,ndx)
        .  .  SET RES=hfill(cndx,jobno)
        SET t2=$ZGETJPI(0,"CPUTIM")
        SET et2=$H
	do RESULT^seqlcl(^opname(2),t1,t2,et1,et2)
	q
GETOP; $GET
	SET ^opname(3)="GETOP"
	SET et1=$H
        SET t1=$ZGETJPI(0,"CPUTIM")
        FOR rep=1:1:repeat DO
        .  FOR ndx=1:1:prime-1 D
	.  .  SET cndx=cust(1+(ndx#ctop))_ndx
	.  .  SET RES=$GET(afill(jobno,ndx))
        .  .  SET RES=$GET(bfill(ndx,cndx))
        .  .  SET RES=$GET(dfill(jobno,cndx))
        .  .  SET RES=$GET(efill(jobno,rep,ndx))
        .  .  SET RES=$GET(ffill(cndx,ndx,3.14))
        .  .  SET RES=$GET(gfill(rep,ndx))
        .  .  SET RES=$GET(hfill(cndx,jobno))
        SET t2=$ZGETJPI(0,"CPUTIM")
        SET et2=$H
	do RESULT^seqlcl(^opname(3),t1,t2,et1,et2)
	q
DATAOP; $DATA
	SET ^opname(4)="DATAOP"
	SET et1=$H
        SET t1=$ZGETJPI(0,"CPUTIM")
        FOR rep=1:1:repeat DO
        .  FOR ndx=1:1:prime-1 D
	.  .  SET cndx=cust(1+(ndx#ctop))_ndx
	.  .  SET RES=$DATA(afill(jobno,ndx))
        .  .  SET RES=$DATA(bfill(ndx,cndx))
        .  .  SET RES=$DATA(dfill(jobno,cndx))
        .  .  SET RES=$DATA(efill(jobno,rep,ndx))
        .  .  SET RES=$DATA(ffill(cndx,ndx,3.14))
        .  .  SET RES=$DATA(gfill(rep,ndx))
        .  .  SET RES=$DATA(hfill(cndx,jobno))
        SET t2=$ZGETJPI(0,"CPUTIM")
        SET et2=$H
	do RESULT^seqlcl(^opname(4),t1,t2,et1,et2)
	q
ORDEROP; $ORDER
	SET ^opname(5)="ORDEROP"
	SET et1=$H
        SET t1=$ZGETJPI(0,"CPUTIM")
        FOR rep=1:1:repeat DO
        .  FOR ndx=1:1:prime-1 D
	.  .  SET cndx=cust(1+(ndx#ctop))_ndx
	.  .  SET RES=$ORDER(afill(jobno,ndx))
        .  .  SET RES=$ORDER(bfill(ndx,cndx))
        .  .  SET RES=$ORDER(dfill(jobno,cndx))
        .  .  SET RES=$ORDER(efill(jobno,rep,ndx))
        .  .  SET RES=$ORDER(ffill(cndx,ndx,3.14))
        .  .  SET RES=$ORDER(gfill(rep,ndx))
        .  .  SET RES=$ORDER(hfill(cndx,jobno))
        SET t2=$ZGETJPI(0,"CPUTIM")
        SET et2=$H
	do RESULT^seqlcl(^opname(5),t1,t2,et1,et2)
	q
ZPREVOP; $ORDER(x,-1)
	SET ^opname(6)="ZPREVOP"
	SET et1=$H
        SET t1=$ZGETJPI(0,"CPUTIM")
        FOR rep=1:1:repeat DO
        .  FOR ndx=1:1:prime-1 D
	.  .  SET cndx=cust(1+(ndx#ctop))_ndx
	.  .  SET RES=$ORDER(afill(jobno,ndx),-1)
        .  .  SET RES=$ORDER(bfill(ndx,cndx),-1)
        .  .  SET RES=$ORDER(dfill(jobno,cndx),-1)
        .  .  SET RES=$ORDER(efill(jobno,rep,ndx),-1)
        .  .  SET RES=$ORDER(ffill(cndx,ndx,3.14),-1)
        .  .  SET RES=$ORDER(gfill(rep,ndx),-1)
        .  .  SET RES=$ORDER(hfill(cndx,jobno),-1)
        SET t2=$ZGETJPI(0,"CPUTIM")
        SET et2=$H
	do RESULT^seqlcl(^opname(6),t1,t2,et1,et2)
	q
QUERYOP; $QUERY
	SET ^opname(7)="QUERYOP"
	SET et1=$H
        SET t1=$ZGETJPI(0,"CPUTIM")
        FOR rep=1:1:repeat DO
        .  FOR ndx=1:1:prime-1 D
	.  .  SET cndx=cust(1+(ndx#ctop))_ndx
	.  .  SET RES=$QUERY(afill(jobno,ndx))
        .  .  SET RES=$QUERY(bfill(ndx,cndx))
        .  .  SET RES=$QUERY(dfill(jobno,cndx))
        .  .  SET RES=$QUERY(efill(jobno,rep,ndx))
        .  .  SET RES=$QUERY(ffill(cndx,ndx,3.14))
        .  .  SET RES=$QUERY(gfill(rep,ndx))
        .  .  SET RES=$QUERY(hfill(cndx,jobno))
        SET t2=$ZGETJPI(0,"CPUTIM")
        SET et2=$H
	do RESULT^seqlcl(^opname(7),t1,t2,et1,et2)
	q
KILLOP; KILL
	SET ^opname(8)="KILLOP"
	SET et1=$H
        SET t1=$ZGETJPI(0,"CPUTIM")
        FOR rep=1:1:repeat DO
        .  FOR ndx=1:1:prime-1 D
	.  .  SET cndx=cust(1+(ndx#ctop))_ndx
	.  .  KILL afill(jobno,ndx)
        .  .  KILL bfill(ndx,cndx)
        .  .  KILL dfill(jobno,cndx)
        .  .  KILL efill(jobno,rep,ndx)
        .  .  KILL ffill(cndx,ndx,3.14)
        .  .  KILL gfill(rep,ndx)
        .  .  KILL hfill(cndx,jobno)
        SET t2=$ZGETJPI(0,"CPUTIM")
        SET et2=$H
	do RESULT^seqlcl(^opname(8),t1,t2,et1,et2)
	q
NULLOP; Null operation 
	SET root=root(jobno#totroot+1)
	SET et3=$H
        SET t3=$ZGETJPI(0,"CPUTIM")
        FOR rep=1:1:repeat DO
        .  FOR ndx=1:1:prime-1 D
	.  .  SET cndx=cust(1+(ndx#ctop))_ndx
        SET t4=$ZGETJPI(0,"CPUTIM")
	SET et4=$H
	q
DUMSET;  Dummy Sets
        FOR j=1:1:repeat
        .  FOR i=1:1:prime-1 D
	.  .  SET afill(jobno,j,i)=$j(j,30)
	.  .  SET bfill(jobno,j,i)=$j(i,30)
	.  .  SET dfill(jobno,j,i)=$j(i,30)
	.  .  SET efill(jobno,j,i)=$j(j,40)
	.  .  SET ffill(jobno,j,i)=$j(i,30)
	.  .  SET gfill(jobno,j,i)=$j(j,30)
	.  .  SET hfill(jobno,j,i)=$j(i,30)
	q
DUMKILL;  Dummy Kill
        FOR j=1:1:repeat
        .  FOR i=1:1:prime-1 D
	.  .  KILL afill(jobno,j,i)
	.  .  KILL bfill(jobno,j,i)
	.  .  KILL dfill(jobno,j,i)
	.  .  KILL efill(jobno,j,i)
	.  .  KILL ffill(jobno,j,i)
	.  .  KILL gfill(jobno,j,i)
	.  .  KILL hfill(jobno,j,i)
	q
RESULT(opname,t1,t2,et1,et2)
    	do NULLOP^seqlcl
	SET cputime=t2-t1
	SET cpuovrhd=t4-t3
	SET elptime=$$^difftime(et2,et1)
	SET elpovrhd=$$^difftime(et4,et3)
	if (cpuovrhd>(cputime))  W "TEST-E-SPEED_TEST: cpu time overhead is more than cpu time!!!  "," t1=",t1," t2=",t2," t3=",t3," t4=",t4,!  
	if (elpovrhd>(elptime))  W "TEST-E-SPEED_TEST: elapse time overhead is more than elapse time!!!  "," et1=",et1," et2=",et2," et3=",et3," et4=",et4,!  
	if (elptime<1) SET elptime=1
	if (cputime<1) SET cputime=1
        SET ^cputime(^image,^typestr,^jnlstr,opname,^order,jobno,^run)=cputime-cpuovrhd
        SET ^elaptime(^image,^typestr,^jnlstr,opname,^order,jobno,^run)=elptime-elpovrhd
        SET ^cpuovrhd(^image,^typestr,^jnlstr,opname,^order,jobno,^run)=$j((100.0*(cpuovrhd)/(cputime)),7,2)
        SET ^elpovrhd(^image,^typestr,^jnlstr,opname,^order,jobno,^run)=$j((100.0*(elpovrhd)/(elptime)),7,2)
