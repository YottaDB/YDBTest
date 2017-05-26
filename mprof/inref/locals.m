locals	; Test of access to MUMPS locals
	w !,"Test of access to MUMPS locals",!
	k A
	do data,indir,updown,kill,volume
	q

data	s A(1)="A(1)",D="|",ERR=0
	d EXAM("set A(1)",A(1),"A(1)")
	s k=1,d(1)=10,d(2)=1,d(3)=0
	s ITEM="A|A(1)|A(2)"
	f x=$d(A),$d(A(1)),$d(A(2))  do EXAM("$d("_$p(ITEM,D,k)_")",x,d(k)) s k=k+1
	s A(2)="A(2)",A(2.0005)="A(2.0005)"
	s k=1,o(1)=1,o(2)=1,o(3)=1,o(4)=2,o(5)=2.0005
	s ITEM="A("""")|A(0.9999)|A(0.1)|A(1.1)|A(2)"
	f x=$o(A("")),$o(A(0.9999)),$o(A(0.1)),$o(A(1.1)),$o(A(2))  do EXAM("$o("_$p(ITEM,D,k)_")",x,o(k)) s k=k+1
	s k=1
	s ITEM="A(-1)|A(0.9999)|A(0.1)|A(1.1)|A(2)"
	f x=$n(A(-1)),$n(A(0.9999)),$n(A(0.1)),$n(A(1.1)),$n(A(2))  do EXAM("$n("_$p(ITEM,D,k)_")",x,o(k)) s k=k+1
	k A
	d EXAM("kill A  $d(A(1))",$d(A(1)),0),EXAM("kill A  $d(A)",$d(A),0)
	i ERR=0  w "d  PASS",!
	q

indir	s A(1)="A(1)",D="|",ERR=0
	s ITEM="A|A(1)|A(2)"
	f k=1:1:3  s x=$p(ITEM,D,k) do EXAM("$d("_x_")",$d(@x),d(k)) 
	s A(2)="A(2)",A(2.0005)="A(2.0005)"
	s k=1,o(1)=1,o(2)=1,o(3)=1,o(4)=2,o(5)=2.0005
	s ITEM="A("""")|A(0.9999)|A(0.1)|A(1.1)|A(2)"
	f k=1:1:3  s x=$p(ITEM,D,k) do EXAM("$o("_x_")",$o(@x),o(k)) 
	i ERR=0  w "i  PASS",!
	k A
	q

updown
	s ERR=0
	k A
	f i=0:1:2 f j=0:0.0005:0.001 s A(i+j)="A("_(i+j)_")"
	s x="",z=""
	f i=0:1:2 f j=0:0.0005:0.001 d 
	.	s x=$o(A(x)),y="A("_(i+j)_")"  
	.	do EXAM("increasing $o("_z_")",x,i+j),EXAM("set "_y,A(i+j),y) 
	.	s z=x
	k A
	f i=2:-1:0 f j=0.001:-0.0005:0 s A(i+j)="A("_(i+j)_")"
	zwr A
	s x="",z=""
	f i=0:1:2 f j=0:0.0005:0.001 d
	.	s x=$o(A(x)),y="A("_(i+j)_")"  
	.	do EXAM("decreasing $o("_z_")",x,i+j),EXAM("set "_y,A(i+j),y) 
	.	s z=x
	f j=0:0.0005:0.001 f i=0:1:2 s A(i+j)="A("_(i+j)_")"
	s x="",z=""
	f i=0:1:2 f j=0:0.0005:0.001 d
	.	s x=$o(A(x)),y="A("_(i+j)_")"  
	.	do EXAM("increasing 2 $o("_z_")",x,i+j),EXAM("set "_y,A(i+j),y)  
	.	s z=x
	i ERR=0  w "u  PASS",!
	q
kill
	s ERR=0
	k A
	f i=0:1:2 f j=0:0.0005:0.001 s A(i,i+j)="A("_i_","_(i+j)_",string)"
	f i=0:1:2 f j=0:0.0005:0.001 k A(i,i+j,"string")
	do EXAM("kill bottom up",$d(A),10)
	i ERR=0  w "k  PASS",!
	q
volume
	s ERR=0
	k x
	f i=1:2:65 f j=0:2:64 f k=0:.0001:.0032 s x(i,j,k)=i*j*k
	f i=1:2:65 f j=0:2:64 f k=0:.0001:.0032 do EXAM("s x("_i_","_j_","_k_")",x(i,j,k),i*j*k)
	i ERR=0  w "s  PASS",!
	q

EXAM(item,vcomp,vcorr)
	i vcorr=vcomp  q
	w " ** FAIL in ",item,!
	w ?10,"CORRECT  = ",vcorr,!
	w ?10,"COMPUTED = ",vcomp,!
	s ERR=ERR+1
	q
