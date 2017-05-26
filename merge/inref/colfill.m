; act="set"  fills data in
; act="ver"  verifies that the data is in data base
; act="kill" kills the data from the database
in0(act,strlen)
	if strlen<12 w "String length is less than 12"
	if strlen>15 w "String length exceeded 15"
	if $data(^prefix)=0 SET ^prefix="^"
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
	s root(16)=37 
	s root(17)=38 
	s root(18)=39 
	s root(19)=40 
	s root(20)=42 
	do filling^colfill(act,prime,strlen)
	do morefill^colfill
	q

filling(act,prime,maxlen)
	SET gblname(1)="A"
	SET gblname(2)="B"
	SET temp(1)="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWX0123456789"
	SET temp(2)="zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDC0246813579"
	SET temp(3)="zzyyxxwwvvuuttssrrqqppoonnmmllkkjjiihhggffeeddccbb9876543210"
	FOR strlen=5:3:maxlen DO
	. FOR i=1:1:maxlen SET ndx(i)=root(i)
	. FOR i=0:1:prime-2 DO
	. . FOR loop1=1:1:3 DO
	. . . SET subs1=""  
	. . . FOR j=1:1:strlen SET subs1=subs1_$e(temp(loop1),ndx(j),ndx(j))  
	. . . FOR loop2=1:1:2 DO
	. . . . SET subs2=""  
	. . . . FOR j=1:1:strlen SET subs2=subs2_$e(temp(loop2),ndx(j),ndx(j))  
	. . . . SET x=^prefix_gblname(1)_"("""_subs2_""","""_subs1_""")"
	. . . . SET y="FIRST"_(strlen*10000000+i)
	. . . . i act="kill" k @x
	. . . . i act="set"  SET @x=y 
	. . . . i act="ver"  do EXAM(ITEM,x,y,$GET(@x))
	. . . . FOR loop3=1:1:2 DO
	. . . . . SET subs3=""  
	. . . . . FOR j=1:1:strlen SET subs3=subs3_$e(temp(loop3),ndx(j),ndx(j))  
	. . . . . SET x=^prefix_gblname(2)_"("""_subs1_""","""_subs2_""","""_subs3_""")"
	. . . . . SET y="SECOND"_(strlen*10000000+i)
	. . . . . i act="kill" k @x
	. . . . . i act="set"  SET @x=y 
	. . . . . i act="ver"  do EXAM(ITEM,x,y,$GET(@x))
	. . FOR j=1:1:maxlen SET ndx(j)=(ndx(j)*root(j))#prime
	i ERR=0 w act," PASS",!
	q

morefill
	for i=1:1:10 SET ^morefill("string"_i,12345,"12345",$c(1,2,3,4,5))=$j(i,5)
	q

EXAM(item,pos,vcorr,vcomp)
	if (ERR>100000000)  q
	i vcorr=vcomp  q
	if ERR=0 w " ** FAIL ",item
	w " verifying global ",pos,!
	w ?10,"CORRECT  = ",vcorr,!
	w ?10,"COMPUTED = ",vcomp,!
	s ERR=ERR+1
	if ERR>100 w "!!!!! TOO MANY ERRORS !!!!",!  q
	q
