;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dbfill	;
in0(act);  act="set"  fills data in
	;  act="kill" kills data from database
	;  act="ver"  verifies that the data is in data base
	s ITEM="Data base fill 0 ",ERR=0
	s t="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	s T="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	s a=0,b=1,c=1
	f i=2:1:1024  D
	.	s a=b,b=c,c=$e(a+b,1,6),lb=a#36+1,rb=b#37+1
	.	s x="^"_$e(t,lb,lb+(c#31)+1)_"("_i_")"
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

in2(act)
	s ITEM="Data base fill 2",ERR=0
	s t="zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRTQPONMLKJIHGFEDCBAa9876543210"
	set T="0,1,234,05,4,5,6789,7,8,9,""zy"",""xwv"",""uts"",""rqpo"",""nmlkjihgfedcba"",""ZYXWVUTSRTQ"",""PON"""
	s a=0,b=1,c=1
	f i=2:1:8192  D
	.	s a=b,b=c,c=$e(a+b,1,6),lb=a#31+1,rb=b#17+1
	.	s p=$p(T,",",rb,rb+(c#17))_","_i,q="^"_$e(t,lb,lb+(c#17))
	.	s x=q_"("_p_",k)"
	.	s y=i_$e(t,lb,lb+rb)
	.	f k=i:1:i+32 do
	.	.	i act="kill" k @x,^data(p,i,k)
	.	.	i act="set"  s @x=y,^data(p,i,k)=y
	.	.	i act="ver"  do EXAM(ITEM,x,y,@x),EXAM(ITEM,"^data("_p_","_i_","_k_")",y,^data(p,i,k))
	i ERR=0 w act," PASS",!
	q

in3(act)
	i act="ver"  w "Cannot verify. Use in3^dbfill only to set and kill"   h
	s ITEM="Data base fill 3",ERR=0
	s t="zzyyxxwwvvuuttssrrqqppoonnmmllkkjjiihhggffeeddccbbaaZaYbXcWdVeUfTgShRiTkQlPmOnNoMpLqKrJsItHuGvFwExDyCzBzAa9876543210"
	s T="10,12,13,14,15,16,17,18,111,222,333,4444,55555,6666,66,""HHH"",""RTQPO"",""NMLKJ"",""IHG"",""FED"",""CBA"",""a987"",654,32,10"
	s S="",u=" "  f k=32:1:126 s v=u,u=$c(k),S=S_u_v_k
	s a=0,b=1,c=1
	f i=2:1:16384  D
	.	s a=b,b=c,c=$e(a+b,1,6),lb=a#47+1,rb=b#23+1
	.	s q=$p(T,",",rb,rb+(c#23))
	.	s x="^"_$e(t,lb,lb+(c#31))_"("_q_")"
	.	s lb=lb*8,rb=rb*17
	.	s y=$s(lb<rb:$e(S,lb,rb),1:S)
	.	s tmp=$d(@x)
	.	f k=i:1:i+128 do
	.	.	i act="kill" k ^(k)
	.	.	i act="set"  s ^(k)=k_y
	.	.	i act="ver"  do EXAM(ITEM,x_k,k_y,^(k))
	i ERR=0 w act," PASS",!
	q

in4(act)
	f i=1:1:1000  D
	.	i act="set"  s ^a(i)=i
	q

in5(act)
	f i=1:1:1000  D
	.	i act="set" do
	.	.	s ^a234567(i)=i
	.	.	s ^b2345678(i)=i
	.	.	s ^c23456789(i)=i
	.	.	s ^d23456789012345(i)=i
	.	.	s ^e234567890123456(i)=i
	.	.	s ^f234567890123456789012345(i)=i
	.	.	s ^g23456789012345678901234567890(i)=i
	.	.	s ^h234567890123456789012345678901(i)=i
	q

EXAM(item,pos,vcorr,vcomp)
	i vcorr=vcomp  q
	w " ** TEST-E-FAIL ",item," verifying global ",pos,!
	w ?10,"CORRECT  = ",vcorr,!
	w ?10,"COMPUTED = ",vcomp,!
	s ERR=ERR+1
	q
