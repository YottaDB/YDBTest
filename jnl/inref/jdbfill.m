jdbfill	;
	; Actually this is almost subset of dbfill.m; But it has some extra flags;
in0(act) ; act="set"  fills data in
	;  act="ver"  verifies that the data is in data base
	s ITEM="Data base fill 0 ",ERR=0
	s t="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	s T="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	s a=0,b=1,c=1
	f i=2:1:1024  D
	.	s a=b,b=c,c=$e(a+b,1,6),lb=a#36+1,rb=b#37+1  
	.	s x="^"_$e(t,lb,lb+(c#11)+1)_"("_i_")"
	.	s y=$e(T,rb,rb+(c#17))_c
	.	i act="kill" k @x
	.	i act="set"  s @x=y
	.	i act="ver"  do EXAM(ITEM,x,y,@x)
	i ERR=0 w act," PASS",!
	q

in1(act)
	s ITEM="Data base fill 1",ERR=0
	s t="ZYXWVUTSRTQPONMLKJIHGFEDCBAzyxwvutsrtqponmlkjihgfedcbaA9876543210"
	s T="zyxwvutsrtqponmlkjihgfedcbaZYXWVUTSRTQPONMLKJIHGFEDCBAa9876543210"
	s a=0,b=1,c=1
	f i=2048:-1:0  D
	.	s a=b,b=c,c=$e(a+b,1,6),lb=a#31+1,rb=b#29+1  
	.	s p=$e(t,lb,lb+rb)_i
	.	s y=$e(T,rb,rb+lb)_p
	.	i act="kill" k ^data(p)
	.	i act="set"  s ^data=i,^data(p)=y
	.	i act="ver"  do EXAM(ITEM,"^data("_p_")",y,^data(p))
	i ERR=0 w act," PASS",!
	q

EXAM(item,pos,vcorr,vcomp)
	i vcorr=vcomp  q
	w " ** FAIL ",item," verifying global ",pos,!
	w ?10,"CORRECT  = ",vcorr,!
	w ?10,"COMPUTED = ",vcomp,!
	s ERR=ERR+1
	q
