arith(precis)	; Test of arithmetic operators -  ** Incomplete **
	s ITEM="Numeric Test "
	w ITEM,!
	s BIAS=30,I=0
	s zeroes="000000000000000000000000000000000000000000000"
	s ones="11111111111111111111111111111111111111111111111"
	s tail=$$zs(precis-1),lead="."_tail,short3=$$zs(precis-2),half0=$$zs(precis\2-1)
	s half1=$e(ones,1,precis\2)
	s sign="1,1,1,0,0,0,0,0,0,0,0,0"
	s expo="0,0,0,0,0,0,0,0,0,5,-5,0"
	s intl="1,2,2,0,0,1,1,1,1,1,1,2"
	s fral="0,0,0,"_precis_","_(precis\2)_",0,0,"_precis_",4,3,3,0"
	F J="-1","-10","-37",lead_"1","."_half0_"1","0","1","1."_half0_half1,"1.0001","1.234E+5","1.234E-5","10" D INIT
	;F J="1024","1"_tail,"123.1","123WIERD","1E+15","1E+20","1E+30","1E+6","1E-15","1E-3","1E-30","2" D INIT
	;F J="2.123E+4","2.123E-4","2"_short3_".001","223.E+8AL","23","23456.1234567","234567890.111","ALFRED" D INIT
	;
	do unary(I)
	do adop(I)
	do mulop(I)
	;do divop(I)
	;do modop(I)
	q

INIT	S I=I+1,Q(I)=J
	Q

unary(I)
	w "  unary operators ",!
	s ERR=0
	F A=1:1:I S X=Q(A)  d EXAM("+"," + "_X,+X,$$un(0,A,X))
	F A=1:1:I S X=Q(A)  d EXAM("-"," + "_X,-X,$$un(1,A,X))
	i ERR=0	 w "u  PASS",!
	q

adop(I)
	w "  addition - subtraction",!
	s ERR=0
	F A=1:1:I F B=1:1:I S X=Q(A),Y=Q(B)  D
		  .  d:$$eqsig(A,B) EXAM("a",X_" + "_Y,X+Y,$$add(A,B,X,Y))
		  .  d:'$$eqsig(A,B) EXAM("a",X_" + "_Y,X+Y,$$sub(1,A,B,X,Y))
	i ERR=0	 w "a  PASS",!
	q
	s ERR=0
	F A=1:1:I F B=1:1:I S X=Q(A),Y=Q(B)  D
		  .  d:$$eqsig(A,B) EXAM("s",X_" - "_Y,X-Y,$$sub(0,A,B,X,Y))
		  .  d:'$$eqsig(A,B) EXAM("s",X_" - "_Y,X-Y,$$add(A,B,X,Y))
	i ERR=0	 w "s  PASS",!
	q

mulop(I)
	w "  multiplication ",!
	s ERR=0
	F A=1:1:I F B=1:1:I S X=Q(A),Y=Q(B)  d EXAM("m",X_" * "_Y,X*Y,$$mul(A,B,X,Y))
	i ERR=0	 w "m  PASS",!
	q

divop(I)
	w "  division - integer division ",!
	s ERR=0
	F A=1:1:I F B=1:1:I S X=Q(A),Y=Q(B)  d EXAM("d",X_" / "_Y,X/Y,$$div(A,B,X,Y))
	i ERR=0	 w "d  PASS",!
	s ERR=0
	F A=1:1:I F B=1:1:I S X=Q(A),Y=Q(B)  d EXAM("i",X_" \ "_Y,X\Y,$$idiv(A,B,X,Y))
	i ERR=0	 w "i  PASS",!
	q

modop(I)
	w "  modulo ",!
	s ERR=0
	F A=1:1:I F B=1:1:I S X=Q(A),Y=Q(B)  d EXAM("mo",X_" * "_Y,X*Y,$$mod(A,B,X,Y))
	i ERR=0	 w "mo PASS",!
	q

un(sg,i,x) 
	new neg,as,rev
	s as=$$biased(i,x)
	s neg=(sg'=$p(sign,",",i))
	q $$fix2can(neg,$$dot(i,x),as,0)

div(A,B,X,Y) q
idiv(A,B,X,Y) q
mod(A,B,X,Y) q

add(i,j,x,y)
	; adds numbers scaled by BIAS
	new c,d,sum,as,bs,k,diff,rght,dot
	s as=$$biased(i,x),bs=$$biased(j,y)
	s da=$$dot(i,x),db=$$dot(j,y),diff=da-db
	s rght=$$max($l(as),$l(bs))+$s(diff>0:diff,1:0)
	s sum="",c=0
	f k=rght:-1:1 q:($e(as,k)'="")!($e(bs,k-diff)'="") 
	f k=k:-1:$s(diff'<0:diff+1,1:1)  s d=c+$e(as,k)+$e(bs,k-diff)  s:d<10 sum=d_sum,c=0  s:d'<10 c=1,sum=(d-10)_sum
	f k=diff:-1:1    s d=c+$e(as,k)       s:d<10 sum=d_sum,c=0  s:d'<10 c=1,sum=(d-10)_sum
	f k=0:-1:diff+1  s d=c+$e(bs,k-diff)  s:d<10 sum=d_sum,c=0  s:d'<10 c=1,sum=(d-10)_sum
	s dot=$$max(da,db)
	s:d=0 sum=$e(sum,2,60),dot=dot-1
	s:c=1 sum=1_sum,dot=dot+1
	q $$fix2can($p(sign,",",i),dot,sum,0)

sub(op,i,j,x,y)
	; subtracts numbers scaled by BIAS
	new bor,sum,as,bs,dot,k,l
	s da=$$dot(i,x),db=$$dot(j,y),diff=da-db
	s as=$$biased(i,x),bs=$$biased(j,y)  
	s rght=$$max($l(as),$l(bs))+$s(diff>0:diff,1:0)
	f l=rght:-1:1 q:(($e(as,l)'="")!($e(bs,l-diff)'=""))
	s sum="",bor=0,at=0,d=0
	i $$less(diff,bs,as) s at=-1 d
	.	f k=l:-1:diff+1  s d=$e(as,k)-$e(bs,k-diff)-bor  s:d'<0 sum=d_sum,bor=0  s:d<0 bor=1,sum=(d+10)_sum
	.	f k=diff:-1:1    s d=$e(as,k)-bor                s:d'<0 sum=d_sum,bor=0  s:d<0 bor=1,sum=(d+10)_sum
	i $$exce(diff,bs,as) s at=1  d
	.	f k=l:-1:1       s d=$e(bs,k-diff)-$e(as,k)-bor  s:d'<0 sum=d_sum,bor=0  s:d<0 bor=1,sum=(d+10)_sum
	.	f k=0:-1:diff+1  s d=$e(bs,k-diff)-bor           s:d'<0 sum=d_sum,bor=0  s:d<0 bor=1,sum=(d+10)_sum
	i at=0  q 0
	s dot=$$max(da,db),shrink=0
	s:d=0 sum=$e(sum,2,60),dot=dot-1,shrink=1
	s neg=((at=1)&($p(sign,",",j)=op))!((at=-1)&($p(sign,",",i)=1))
	q $$fix2can(neg,dot,sum,shrink)


mul(i,j,x,y) 
	new k,d,la,as,bs,ps
	s as=$$biased(i,x),la=$l(as)  
	s bs=$$biased(j,y),lb=$l(bs)
	s da=$$dot(i,x),db=$$dot(j,y),dot=da+db
	s ps=$$times(as,bs)
	i $l(ps)'=(la+lb)  s dot=dot-1
	f k=0:1:dot  q:$e(ps,k+1)'=0 
	s ps=$e(ps,k+1,60),dot=dot-k
	s neg=$p(sign,",",j)'=$p(sign,",",i)
	q $$fix2can(neg,dot,ps,0)

times(gs,fs)
	new g,ts,k
	s ts=""
	f k=$l(gs):-1:1 s g=$e(gs,k),ts=$$S(g,fs,ts),fs=fs_0  
	q ts

S(q,xs,ys)
	new w,k,j,c,d,m,low,ss
	s ss="",c=0,j=$l(ys),m=$l(xs),low=$s(j>m:m-j+1,1:1)
	f k=m:-1:low  d
	.	s w=c+(q*$e(xs,k))+$e(ys,j),j=j-1
	.	s:w<10 c=0,d=w  s:w'<10 c=$e(w,1),d=$e(w,2)  
	.	s ss=d_ss
	q $s(c'=0:c_ss,1:ss)

eqsig(i,j) ; equal sign
	q $p(sign,",",i)=$p(sign,",",j)

less(dif,u,v)
	new k
	i dif>0  q 1
	i dif<0  q 0
	f k=1:1:60  q:(+$e(u,k))'=(+$e(v,k))
	q $e(u,k)<$e(v,k)

exce(dif,u,v)
	new k
	i dif<0  q 1
	i dif>0  q 0
	f k=1:1:60  q:(+$e(u,k))'=(+$e(v,k))
	q $e(u,k)>$e(v,k)

biased(i,n) ; maps rational number to biased natural
	new start,decp,end
	s start=1+$p(sign,",",i)
	s decp=start+$p(intl,",",i)
	s end=decp+$p(fral,",",i)
	q $e(n,start,decp-1)_$e(n,decp+1,end)

dot(i,n) ; position of the decimal point
	q $p(intl,",",i)+$p(expo,",",i)

fix2can(neg,dot,fix,shr)
	new d,ds,c,d,L,ld,prec
	i +fix=0  q 0
	s L=$l(fix),prec=precis-shr
	f  q:$e(fix,L)'=0  s L=L-1
	f k=1:1:L  q:$e(fix,k)'=0
	s c=0  
	i L-k+1>prec  s L=prec s:$e(fix,L)>5 c=1  f  q:$e(fix,L)'=0  s L=L-1
	i c=1  f L=L:-1:1  q:$e(fix,L)'=9
	s ds=""  
	f k=dot-1:-1:L s ds=ds_0
	f k=L:-1:dot+1 s d=($e(fix,k)+c)  s:d<10 ds=d_ds,c=0  s:d'<10 ds=(d-10)_ds,c=1
	i dot<L  s ds="."_ds,k=k-1
	f k=k:-1:1     s d=($e(fix,k)+c)  s:d<10 ds=d_ds,c=0  s:d'<10 ds=(d-10)_ds,c=1
	i c=1 s ds=1_ds  i (L=1)&(dot=0)  s ds=1
	s:neg ds="-"_ds
	q ds

EXAM(ind,item,vcomp,vcorr)
	i vcorr=vcomp  q
	s ERR=ERR+1
	w ind,"  ** FAIL ",item,! 
	w "         CORRECT  = ",vcorr,!
	w "         COMPUTED = ",vcomp,!
	q

max(a,b) q $s(a>b:a,1:b)

zs(l)	q $e(zeroes,1,l)
