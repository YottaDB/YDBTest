newpara	;show parameter passing and NEW interaction
	;
	k x s cnt=0
	s c=1 d sub1(.c)
	s cnt=c'=2+$d(x)+cnt,zp=$zpos
	s c=1 d sub2(.c)
	s cnt=c'=2+$d(x)+cnt,zp=$zpos
	s c=1 d sub3(.c)
	s cnt=c'=2+$d(x)+cnt,zp=$zpos
	s c=1 d sub4(.c)
	s cnt=c'=2+$d(x)+cnt,zp=$zpos
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
	;
sub1(x)	;
	s cnt=c'=1+(x'=1)+cnt,zp=$zpos
	s x=2
	s cnt=c'=2+(x'=2)+cnt,zp=$zpos
	n c 
	s cnt=x'=2+$d(c)+cnt,zp=$zpos
	s c=1
	s cnt=c'=1+(x'=2)+cnt,zp=$zpos
	q
sub2(x)	;
	s cnt=c'=1+(x'=1)+cnt,zp=$zpos
	s c=2
	s cnt=c'=2+(x'=2)+cnt,zp=$zpos
	n x 
	s cnt=c'=2+$d(x)+cnt,zp=$zpos
	s x=1
	s cnt=x'=1+(c'=2)+cnt,zp=$zpos 
	q
sub3(x)	;
	s cnt=c'=1+(x'=1)+cnt,zp=$zpos
	s c=2
	s cnt=c'=2+(x'=2)+cnt,zp=$zpos
	n c 
	s cnt=x'=2+$d(c)+cnt,zp=$zpos
	s c=1
	s cnt=c'=1+(x'=2)+cnt,zp=$zpos 
	q
sub4(x)	;
	s cnt=c'=1+(x'=1)+cnt,zp=$zpos
	s x=2
	s cnt=c'=2+(x'=2)+cnt,zp=$zpos
	n x 
	s cnt=c'=2+$d(x)+cnt,zp=$zpos
	s x=1
	s cnt=x'=1+(c'=2)+cnt,zp=$zpos 
	q
