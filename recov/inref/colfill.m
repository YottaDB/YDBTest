colfill	;
        ; act="set"  fills data in
	; act="ver"  verifies that the data is in data base
	; act="kill" kills the data from the database

in0(act,strlen)
	if strlen>15 w "String lenght exceeded 15"
	s ITEM="Random database fill for collation  ",ERR=0
	s prime=59
	s root(1)=2
	s root(2)=6
	s root(3)=8
	s root(4)=10
	s root(5)=11
	s root(6)=13
	s root(7)=14
	s root(8)=18
	s root(9)=23
	s root(10)=24
	s root(11)=30
	s root(12)=31
	s root(13)=32
	s root(14)=33
	s root(15)=34
	do filling^colfill(act,prime,strlen)
	q

filling(act,prime,maxlen)
	S gblname(1)="A"
	S gblname(2)="B"
	S temp="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	f strlen=1:1:maxlen DO
	. f i=1:1:strlen s ndx(i)=root(i)
	. f i=0:1:prime-2 D
	. . S alpha=""
	. . f j=1:1:strlen  S alpha=alpha_$e(temp,ndx(j),ndx(j))  
	. . f j=1:1:2 D
	. . .  S x="^"_gblname(j)_"("""_alpha_""")"
	. . .  S y=i
	. . .  i act="kill" k @x
	. . .  i act="set"  s @x=y 
	. . .  i act="ver"  do EXAM(ITEM,x,y,$GET(@x))
	. . f j=1:1:strlen S ndx(j)=(ndx(j)*root(j))#prime
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
