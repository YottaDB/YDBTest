numfill	;
	; Small fill (each data record is 15 bytes value on Right Hand Side)
        ; act="set"  fills data in
	; act="ver"  verifies that the data is in data base
	; act="kill" kills the data from the database
	; subs=Number of subscript.  (any number from 1:5)
	; regcnt=Number of regions in addition to DEFAULT (1:8) 

in0(act,subs,regcnt)
	s ITEM="Random database fill 0 ",ERR=0
	s prime=29
	s root(1)=2
	s root(2)=3
	s root(3)=8
	s root(4)=10
	s root(5)=11
	do filling^numfill(act,prime,subs,regcnt)
	q

in1(act,subs,regcnt)
	s ITEM="Random database fill 1 ",ERR=0
	s prime=251
	s root(1)=6
	s root(2)=11
	s root(3)=14
	s root(4)=18
	s root(5)=19
	s root(6)=24
	s root(7)=26
	s root(8)=29
	s root(9)=30
	s root(10)=33
	do filling^numfill(act,prime,subs,regcnt)
	q

in2(act,subs,regcnt)
	s ITEM="Random database fill 2 ",ERR=0
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
	do filling^numfill(act,prime,subs,regcnt)
	q

in3(act,subs,regcnt)
	s ITEM="Random database fill 3 ",ERR=0
	s prime=1009
	s root(1)=11
	s root(2)=17
	s root(3)=22
	s root(4)=26
	s root(5)=31
	do filling^numfill(act,prime,subs,regcnt)
	q

in4(act,subs,regcnt)
	s ITEM="Random database fill 4 ",ERR=0
	s prime=10007
	s root(1)=5
	s root(2)=7
	s root(3)=10
	s root(4)=14
	s root(5)=15
	do filling^numfill(act,prime,subs,regcnt)
	q

in5(act,subs,regcnt)
	s ITEM="Random database fill 5 ",ERR=0
	s prime=100003
	s root(1)=2
	s root(2)=3
	s root(3)=5
	s root(4)=7
	s root(5)=29
	do filling^numfill(act,prime,subs,regcnt)
	q

in6(act,pn,regcnto)
	s ITEM="Data base fill 6 ",ERR=0
	s prime=1000003
	s root(1)=2
	s root(2)=5
	s root(3)=7
	s root(4)=11
	s root(5)=12
	do filling^numfill(act,prime,subs,regcnt)
	q


filling(act,prime,subs,regcnt)
	if subs>5 w "Too many subscripts!"  q
	if regcnt>8 w "Too many regions!"  q
	f i=1:1:5 s ndx(i)=root(i)
	if $data(^prefix)=0 SET ^prefix="^"
	f i=0:1:prime-2 D
	. S regname="ABCDEFGHI" 
	. f j=i:1:i+regcnt D
	. .  s regindex=j#(regcnt+1)+1
	. .  s rhssize=i#5+10
	. .  s x=^prefix_$e(regname,regindex,regindex)_"GLOBALVAR1"_"("
	. .  if i#2=0  SET sign=1
	. .  else  SET sign=-1
	. .  SET tndx=sign*ndx(1) S x=x_tndx
	. .  f k=2:1:subs-1 SET tndx=sign*ndx(k)        S x=x_","_tndx
	. .  f m=k:1:subs   SET tndx=sign*100.01*ndx(m) S x=x_","_tndx
	. .  S x=x_")"
	. .  ; right justify 
	. .  s y=$j(ndx(1),rhssize)
	. .  i act="kill" k @x
	. .  i act="set"  s @x=y 
	. .  i act="ver"  do EXAM(ITEM,x,y,$GET(@x))
	. f k=1:1:subs S ndx(k)=(ndx(k)*root(k))#prime
	i ERR=0 w act," PASS",!
	q


EXAM(item,pos,vcorr,vcomp)
	if (ERR>100)  q
	i vcorr=vcomp  q
	if ERR=0 w " ** FAIL ",item," verifying global ",pos,!
	w ?10,"CORRECT  = ",vcorr,!
	w ?10,"COMPUTED = ",vcomp,!
	s ERR=ERR+1
	if ERR>100 w "!!!!! TOO MANY ERRORS !!!!",!  q
	q
