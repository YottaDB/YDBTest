TDBFILL	;
in(action,typ)
	s action=$tr(action,"skv","SKV")
	s ITEM="Data base fill "_typ,ERR=0
	s mod1=$s(typ:31,1:36),mod2=$s(typ:29,1:37),mod3=$s(typ:16,1:11),mod4=$s(typ:31,1:17)
	i typ d
	. s t="ZYXWVUTSRTQPONMLKJIHGFEDCBAzyxwvutsrtqponmlkjihgfedcbaA9876543210"
	. s T="zyxwvutsrtqponmlkjihgfedcbaZYXWVUTSRTQPONMLKJIHGFEDCBAa9876543210"
	e  d
	. s t="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	. s T="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	s a=0,b=1,c=1
	f i=2:1:128 D
	.	s a=b,b=c,c=a+b,lb=a#mod1+1,rb=b#mod2+1  i c>999999 s c=$e(c,1,6)
	.	s x="^"_$e(t,lb,lb+(c#mod3)+typ)_"("_i_")"
	.	s y=$e(T,rb,rb+(c#mod4))
	.	i action="S" s @x=y q
	.	i action="K" k @x q
	.	i action="V" do EXAM(ITEM,x,y,$g(@x,"**UNDEF**"))
	q

EXAM(item,pos,vcorr,vcomp)
	i vcorr=vcomp  q
	w !," ** FAIL ",item," verifying global ",pos,!
	w ?10,"CORRECT  = ",vcorr,!
	w ?10,"COMPUTED = ",vcomp,!
	s ERR=ERR+1
	x act
	q
