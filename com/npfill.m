npfill	;
	; Random fill using prime field, so that they can be verified
        ; act="set"  fills data in
	; act="ver"  verifies that the data is in data base
	; act="kill" kills the data from the database

in0(act,pno,iter)
	SET ITEM="Data base fill 0 ",ERR=0,MAXERR=10
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
	do filling^npfill(act,prime,root(pno),iter)
	q
	;
in1(act,pno,iter)
	SET ITEM="Data base fill 1 ",ERR=0,MAXERR=10
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
	do filling^npfill(act,prime,root(pno),iter)
	q
	;
in2(act,pno,iter)
	SET ITEM="Data base fill 2 ",ERR=0,MAXERR=10
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
	do filling^npfill(act,prime,root(pno),iter)
	q
	;
in3(act,pno,iter)
	SET ITEM="Data base fill 3 ",ERR=0,MAXERR=10
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
	do filling^npfill(act,prime,root(pno),iter)
	q
	;	
in4(act,pno,iter)
	SET ITEM="Data base fill 4 ",ERR=0,MAXERR=10
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
	do filling^npfill(act,prime,root(pno),iter)
	q
	;	

filling(act,prime,root,iter)
	new ndx
	SET ndx=1
	SET multibytestr=$$^getunitemplate()
	S regname="abcdefghi" 
	if act'="kill",act'="set",act'="ver"  W "Do not know what to do!!!",!  Q
	f i=0:1:prime-2 D  q:ERR>MAXERR
	. SET ndx=(ndx*root)#prime
	. SET subs="("_""""_"abcdefgh"_multibytestr_ndx_""""_","_iter_")"	
	. f j=i:1:i+8 D
	. .  SET regindex=(j#9)+1
	. .  SET x="^"_$e(regname,regindex,regindex)_"randomfilling"_subs
	. .  SET y=ndx*1000000+iter
	. .  i act="kill" k @x
	. .  i act="set"  SET @x=y 
	. .  i act="ver"  do EXAM(ITEM,x,y,$GET(@x))
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
