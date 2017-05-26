nindfill	;
	; Pseu-Random fill using prime field, so that they can be verified
        ; act="set"  fills data in
	; act="ver"  verifies that the data is in data base
	; act="kill" kills the data from the database

in0(act,pno,iter)
	SET ITEM="Data base nindfill 0 ",ERR=0,MAXERR=10
	SET prime=53
	SET root(1)=12
	SET root(2)=14
	SET root(3)=18
	SET root(4)=19
	SET root(5)=20
	SET root(6)=21
	SET root(7)=22
	SET root(8)=26
	SET root(9)=27
	SET root(10)=31                   
	do filling^nindfill(act,prime,root(pno),iter)
	q
	;
in1(act,pno,iter)
	SET ITEM="Data base nindfill 1 ",ERR=0,MAXERR=10
	SET prime=101
	SET root(1)=11
	SET root(2)=12
	SET root(3)=15
	SET root(4)=18
	SET root(5)=26
	SET root(6)=27
	SET root(7)=28
	SET root(8)=29
	SET root(9)=34
	SET root(10)=35          
	do filling^nindfill(act,prime,root(pno),iter)
	q
	;
in2(act,pno,iter)
	SET ITEM="Data base nindfill 2 ",ERR=0,MAXERR=10
	SET prime=251
        SET root(1)=6
        SET root(2)=11
        SET root(3)=14
        SET root(4)=18
        SET root(5)=19
        SET root(6)=24
        SET root(7)=26
        SET root(8)=29
        SET root(9)=30
        SET root(10)=33            
	do filling^nindfill(act,prime,root(pno),iter)
	q
	;
in3(act,pno,iter)
	SET ITEM="Data base nindfill 3 ",ERR=0,MAXERR=10
	SET prime=503
	SET root(1)=5
	SET root(2)=10
	SET root(3)=15
	SET root(4)=17
	SET root(5)=19
	SET root(6)=20
	SET root(7)=29
	SET root(8)=30
	SET root(9)=31
	SET root(10)=34
	do filling^nindfill(act,prime,root(pno),iter)
	q
	;	
in4(act,pno,iter)
	SET ITEM="Data base nindfill 4 ",ERR=0,MAXERR=10
	SET prime=1009
	SET root(1)=11
	SET root(2)=17
	SET root(3)=22
	SET root(4)=26
	SET root(5)=31
	SET root(6)=33
	SET root(7)=34
	SET root(8)=38
	SET root(9)=46
	SET root(10)=51             
	do filling^nindfill(act,prime,root(pno),iter)
	q
	;	
in5(act,pno,iter)
	SET ITEM="Data base nindfill 5 ",ERR=0,MAXERR=10
	SET prime=2003
	SET root(1)=15
	SET root(2)=18
	SET root(3)=20
	SET root(4)=24
	SET root(5)=26
	SET root(6)=28
	SET root(7)=29
	SET root(8)=31
	SET root(9)=33
	SET root(10)=37                     
	do filling^nindfill(act,prime,root(pno),iter)
	q
filling(act,prime,root,iter)
	new ndx,ndx1,ndx2,i,val
	SET ndx=1
	SET multibytestr=$$^getunitemplate()
	if act'="kill",act'="set",act'="ver"  W "Do not know what to do!!!",!  Q
	f i=0:1:prime-2 D  q:ERR>MAXERR
	. SET ndx=(ndx*root)#prime
	. SET ndx1="abcdefghijklmnopqrstuvwxyz"_multibytestr_ndx
	. SET ndx2="ABCDEFGHIJKLMNOPQRSTUVWXYZ"_multibytestr_iter
	. SET val=ndx*1000000+iter
	. if act="kill" DO
	. .  kill ^a(ndx1,ndx2)
	. .  kill ^b(ndx1,ndx2)
	. .  kill ^c(ndx1,ndx2)
	. .  kill ^d(ndx1,ndx2)
	. .  kill ^e(ndx1,ndx2)
	. .  kill ^f(ndx1,ndx2)
	. .  kill ^g(ndx1,ndx2)
	. .  kill ^h(ndx1,ndx2)
	. .  kill ^i(ndx1,ndx2)
	. if act="set" DO
 	. .  set ^a(ndx1,ndx2)=val+1
 	. .  set ^b(ndx1,ndx2)=val+2
 	. .  set ^c(ndx1,ndx2)=val+3
 	. .  set ^d(ndx1,ndx2)=val+4
 	. .  set ^e(ndx1,ndx2)=val+5
 	. .  set ^f(ndx1,ndx2)=val+6
 	. .  set ^g(ndx1,ndx2)=val+7
 	. .  set ^h(ndx1,ndx2)=val+8
 	. .  set ^i(ndx1,ndx2)=val+9
	. if act="ver" DO
 	. .  do EXAM(ITEM,"^a("_ndx1_","_ndx2_")",val+1,$GET(^a(ndx1,ndx2)))
 	. .  do EXAM(ITEM,"^b("_ndx1_","_ndx2_")",val+2,$GET(^b(ndx1,ndx2)))
 	. .  do EXAM(ITEM,"^c("_ndx1_","_ndx2_")",val+3,$GET(^c(ndx1,ndx2)))
 	. .  do EXAM(ITEM,"^d("_ndx1_","_ndx2_")",val+4,$GET(^d(ndx1,ndx2)))
 	. .  do EXAM(ITEM,"^e("_ndx1_","_ndx2_")",val+5,$GET(^e(ndx1,ndx2)))
 	. .  do EXAM(ITEM,"^f("_ndx1_","_ndx2_")",val+6,$GET(^f(ndx1,ndx2)))
 	. .  do EXAM(ITEM,"^g("_ndx1_","_ndx2_")",val+7,$GET(^g(ndx1,ndx2)))
 	. .  do EXAM(ITEM,"^h("_ndx1_","_ndx2_")",val+8,$GET(^h(ndx1,ndx2)))
 	. .  do EXAM(ITEM,"^i("_ndx1_","_ndx2_")",val+9,$GET(^i(ndx1,ndx2)))
	i ERR'=0 w act," FAIL, Error occured.",!
	i ERR>MAXERR w act," Too many Errors.",!
	q


EXAM(item,pos,vcorr,vcomp)
	i vcorr=vcomp  q
	w " ** FAIL ",item," verifying global ",pos,!
	w ?10,"CORRECT  = ",vcorr,!
	w ?10,"COMPUTED = ",vcomp,!
	SET ERR=ERR+1
	q
