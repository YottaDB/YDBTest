pfill1	;
        ; act="set"  fills data in
	; act="ver"  verifies that the data is in data base
	; act="kill" kills the data from the database
in1(act,pno,iter)
	s ITEM="Data base fill 1 ",ERR=0
	s prime=101
	s root(1)=2 
	s root(2)=3 
	s root(3)=7 
	s root(4)=8 
	s root(5)=11 
	s root(6)=12 
	s root(7)=15 
	s root(8)=18 
	s root(9)=26 
	s root(10)=27 
	do filling^pfill1(act,prime,root(pno),iter)
	q

in2(act,pno,iter)
	s ITEM="Data base fill 2 ",ERR=0
	s prime=211
	s root(1)=2 
	s root(2)=3 
	s root(3)=7 
	s root(4)=17 
	s root(5)=22 
	s root(6)=29 
	s root(7)=35 
	s root(8)=39 
	s root(9)=41 
	s root(10)=48 
	do filling^pfill1(act,prime,root(pno),iter)
	q

in3(act,pno,iter)
	s ITEM="Data base fill 3 ",ERR=0
	s prime=307
	s root(1)=5 
	s root(2)=13 
	s root(3)=14 
	s root(4)=21 
	s root(5)=22 
	s root(6)=23 
	s root(7)=29 
	s root(8)=30 
	s root(9)=31 
	s root(10)=43 
	do filling^pfill1(act,prime,root(pno),iter)
	q

in4(act,pno,iter)
	s ITEM="Data base fill 4 ",ERR=0
	s prime=401
	s root(1)=3 
	s root(2)=6 
	s root(3)=12 
	s root(4)=13 
	s root(5)=15 
	s root(6)=17 
	s root(7)=19 
	s root(8)=21 
	s root(9)=23 
	s root(10)=24 
	do filling^pfill1(act,prime,root(pno),iter)
	q

in5(act,pno,iter)
	s ITEM="Data base fill 5 ",ERR=0
	s prime=503
	s root(1)=5 
	s root(2)=10 
	s root(3)=15 
	s root(4)=17 
	s root(5)=19 
	s root(6)=20 
	s root(7)=29 
	s root(8)=30 
	s root(9)=31 
	s root(10)=34 
	do filling^pfill1(act,prime,root(pno),iter)
	q
filling(act,prime,root,iter)
	new ndx
	SET ndx=1
	SET multibytestr=$$^getunitemplate()
	S regname="abcdefghi" 
	if act'="kill",act'="set",act'="ver"  W "Do not know what to do!!!",!  Q
	f i=0:1:prime-2 D 
	. SET ndx=(ndx*root)#prime
	. SET subs="("_""""_"abcdefgh"_multibytestr_ndx_""""_","_iter_")"	
	. f j=i:1:i+8 D
	. .  SET regindex=(j#9)+1
	. .  SET x="^"_$e(regname,regindex,regindex)_"randomfilling"_subs
	. .  SET lclx=$e(regname,regindex,regindex)_"randomfilling"_subs
	. .  SET y=ndx_" "_iter
	. .  i act="kill" k @x
	. .  i act="set"  SET @x=y  SET lclx=y
	. .  i act="ver"  do EXAM(ITEM,x,y,$GET(@x))
	i ERR=0 w act," PASS",!
	q


EXAM(item,pos,vcorr,vcomp)
	i vcorr=vcomp  q
	w " ** FAIL ",item," verifying global ",pos,!
	w ?10,"CORRECT  = ",vcorr,!
	w ?10,"COMPUTED = ",vcomp,!
	SET ERR=ERR+1
	q
