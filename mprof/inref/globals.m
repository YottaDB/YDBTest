globals	; Test of access to MUMPS globals
	w !,"Test of access to MUMPS globals",!
	k ^aA
	do tstd,tsti,updown
	q

tstd	s ^aA(1)="^aA(1)",D="|",ERR=0
	d EXAM("set ^aA(1)",^aA(1),"^aA(1)")
	s k=1,d(1)=10,d(2)=1,d(3)=0
	s ITEM="^aA|^aA(1)|^aA(2)"
	f x=$d(^aA),$d(^aA(1)),$d(^aA(2))  do EXAM("$d("_$p(ITEM,D,k)_")",x,d(k)) s k=k+1
	s ^aA(2)="^aA(2)",^aA(2.0005)="^aA(2.0005)"
	s k=1,o(1)=1,o(2)=1,o(3)=1,o(4)=2,o(5)=2.0005
	s ITEM="^aA("""")|^aA(0.9999)|^aA(0.1)|^aA(1.1)|^aA(2)"
	f x=$o(^aA("")),$o(^aA(0.9999)),$o(^aA(0.1)),$o(^aA(1.1)),$o(^aA(2))  do EXAM("$o("_$p(ITEM,D,k)_")",x,o(k)) s k=k+1
	s k=1
	s ITEM="^aA(-1)|^aA(0.9999)|^aA(0.1)|^aA(1.1)|^aA(2)"
	f x=$n(^aA(-1)),$n(^aA(0.9999)),$n(^aA(0.1)),$n(^aA(1.1)),$n(^aA(2))  do EXAM("$n("_$p(ITEM,D,k)_")",x,o(k)) s k=k+1
	k ^aA
	d EXAM("kill ^aA  $d(^aA(1))",$d(^aA(1)),0),EXAM("kill ^aA  $d(^aA)",$d(^aA),0)
	i ERR=0  w "d  PASS",!
	q

tsti	s ^aA(1)="^aA(1)",D="|",ERR=0
	s ITEM="^aA|^aA(1)|^aA(2)"
	f k=1:1:3  s x=$p(ITEM,D,k) do EXAM("$d("_x_")",$d(@x),d(k)) 
	s ^aA(2)="^aA(2)",^aA(2.0005)="^aA(2.0005)"
	s k=1,o(1)=1,o(2)=1,o(3)=1,o(4)=2,o(5)=2.0005
	s ITEM="^aA("""")|^aA(0.9999)|^aA(0.1)|^aA(1.1)|^aA(2)"
	f k=1:1:3  s x=$p(ITEM,D,k) do EXAM("$o("_x_")",$o(@x),o(k)) 
	i ERR=0  w "i  PASS",!
	k ^aA
	q

updown
	s ERR=0
	k ^aA
	f i=0:1:2 f j=0:0.0005:0.001 s ^aA(i+j)="^aA("_(i+j)_")"
	s x="",z=""
	f i=0:1:2 f j=0:0.0005:0.001 d 
	.	s x=$o(^aA(x)),y="^aA("_(i+j)_")"  
	.	do EXAM("increasing $o("_z_")",x,i+j),EXAM("set "_y,^aA(i+j),y) 
	.	s z=x
	k ^aA
	f i=2:-1:0 f j=0.001:-0.0005:0 s ^aA(i+j)="^aA("_(i+j)_")"
	s x="",z=""
	f i=0:1:2 f j=0:0.0005:0.001 d
	.	s x=$o(^aA(x)),y="^aA("_(i+j)_")"  
	.	do EXAM("decreasing $o("_z_")",x,i+j),EXAM("set "_y,^aA(i+j),y) 
	.	s z=x
	f j=0:0.0005:0.001 f i=0:1:2 s ^aA(i+j)="^aA("_(i+j)_")"
	s x="",z=""
	f i=0:1:2 f j=0:0.0005:0.001 d
	.	s x=$o(^aA(x)),y="^aA("_(i+j)_")"  
	.	do EXAM("increasing 2 $o("_z_")",x,i+j),EXAM("set "_y,^aA(i+j),y)  
	.	s z=x
	i ERR=0  w "u  PASS",!
	q

EXAM(item,vcomp,vcorr)
	i vcorr=vcomp  q
	w " ** FAIL in ",item,!
	w ?10,"CORRECT  = ",vcorr,!
	w ?10,"COMPUTED = ",vcomp,!
	s ERR=ERR+1
	q
