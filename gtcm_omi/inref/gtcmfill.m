dbfill	;
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
	.	i act="kill" s ERR='$$^kill(x)
	.	i act="set"  s ERR='$$^set(x,y)
	.	i act="ver"  do EXAM(ITEM,x,y,$$^get(x))
	i ERR=0 w act," PASS",!
	q

in1(act)
	s ITEM="Data base fill 1",ERR=0
	s t="ZYXWVUTSRTQPONMLKJIHGFEDCBAzyxwvutsrtqponmlkjihgfedcbaA9876543210"
	s T="zyxwvutsrtqponmlkjihgfedcbaZYXWVUTSRTQPONMLKJIHGFEDCBAa9876543210"
	s a=0,b=1,c=1
	f i=2:1:2048  D
	.	s a=b,b=c,c=$e(a+b,1,6),lb=a#31+1,rb=b#29+1  
	.	s p=$e(t,lb,lb+rb)_i
	.	s y=$e(T,rb,rb+lb)_p
	.	s len=150,numsubs=4	; fill up the subscript to fit in some bigger keys
	.	s single=""""_$j(p,len)_"""",subscript=$j(" ",len)
	.	f k=1:1:numsubs-1 s subscript=subscript_","_single
	.	i act="kill" s ERR='$$^kill("^dataasalongvariablename45678901("_subscript_")")
	.	i act="set"  s ERR='$$^set("^dataasalongvariablename45678901("_subscript_")",y)
	.	i act="set",i#500=0  s ERR='$$^set("^dataasalongvariablename45("_subscript_")","testing truncation")
	.	i act="ver"  do EXAM(ITEM,"^dataasalongvariablename45678901("_subscript_")",y,$$^get("^dataasalongvariablename45678901("_subscript_")"))
	i ERR=0 w act," PASS",!
	q

in2(act)
	s ITEM="Data base fill 2",ERR=0
	s t="zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRTQPONMLKJIHGFEDCBAa9876543210"
	s T="""ABCD"",""EF"",""GHI"",""JKLM"",""NOPQRST"",""UVWXYZ"",""abcd"",""efgh"",""ijklm"",""nopq"",""rstuv"",""wxyz"",01,23,45,67,89"
	s a=0,b=1,c=1
	w "in in2^dbfill",!
	w "act = ",act,!
	f i=2:1:8192  D
	.	s a=b,b=c,c=$e(a+b,1,6),lb=a#31+1,rb=b#17+1  
	.	s p=$p(T,",",rb,rb+(c#17))_","_i,q="^"_$e(t,lb)
	.	s x=q_"("_p_",k)"
	.	s y=i_$e(t,lb,lb+rb)
	.	f k=i:1:i+32 do
	.	.	i act="kill" s ERR='$$^kill(x) s ERR='$$^kill("^data("_p_","_i_","_k_")")
	.	.	i act="set"  s ERR='$$^set(x,y) s ERR='$$^set("^data("_p_","_i_","_k_")",y)
	.	.	i act="ver"  do EXAM(ITEM,x,y,$$^get(x)),EXAM(ITEM,"^data("_p_","_i_","_k_")",y,$$^get("^data("_p_","_i_","_k_")"))
	i ERR=0 w act," PASS",!
	q

in3(act)
	s ITEM="Data base fill 3",ERR=0
	s t="zzyyxxwwvvuuttssrrqqppoonnmmllkkjjiihhggffeeddccbbaaZaYbXcWdVeUfTgShRiTkQlPmOnNoMpLqKrJsItHuGvFwExDyCzBzAa9876543210"
	s T="10,12,13,14,15,16,17,18,111,222,333,4444,55555,6666,66,""HHH"",""RTQPO"",""NMLKJ"",""IHG"",""FED"",""CBA"",""a987"",654,32,10"
	s S="",u=" "  f k=32:1:126 s v=u,u=$c(k),S=S_u_v_k
	s a=0,b=1,c=1
	f i=2:1:16384  D
	.	s a=b,b=c,c=$e(a+b,1,6),lb=a#47+1,rb=b#23+1  
	.	s q=$p(T,",",rb,rb+(c#23))
	.	s gvn="^"_$e(t,lb)
	.	s x=gvn_"("_q_")"
	.	s lb=lb*8,rb=rb*17
	.	s y=$s(lb<rb:$e(S,lb,rb),1:S)
	.	s tmp=$$^define(x)
	.	f k=i:1:i+128 do
	.	.	i act="kill" s ERR='$$^kill(gvn_"("_i_","_k_")")
	.	.	i act="set"  s ERR='$$^set(gvn_"("_i_","_k_")",k_y)
	.	.	i act="ver"  do EXAM(ITEM,x_k,k_y,$$^get(gvn_"("_i_","_k_")"))
	i ERR=0 w act," PASS",!
	q

EXAM(item,pos,vcorr,vcomp)
	i vcorr=vcomp  q
	s ERR=ERR+1
	i ERR>32       w " Not reporting any further, too many errors ",! q
	w " ** FAIL ",item," verifying global ",pos,!
	w ?10,"CORRECT  = ",vcorr,!
	w ?10,"COMPUTED = ",vcomp,!
	q
