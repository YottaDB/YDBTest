piece	; Test of $PIECE function
	w !,"Test of $piece",!
	s (p(-1),p(0),p(7))=""
	s p(1)="abc",p(2)="def",p(3)="ghi",p(4)="jkl",p(5)="mno",p(6)="pqr"
	s d="x"
	s P("")="",P("x")=p(1),P("xg")=p(1)_d_p(2)
	s P("xyz")=p(1)_d_p(2)_d_p(3)_d_p(4)_d_p(5)_d_p(6)
	s ITEM="$piece(",ERR=0 
	f d="","x","xg","xyz"  do arg2(P("xyz"),d)
	i ERR=0  w "a  PASS",!
	s ITEM="$piece(",ERR=0 
	f d="x","xy"  do arg3(p(1)_d_p(2)_d_p(3)_d_p(4)_d_p(5)_d_p(6),d)
	i ERR=0  w "b  PASS",!
	s ITEM="$piece(",ERR=0 
	f d="x","xy"  do arg4(p(1)_d_p(2)_d_p(3)_d_p(4)_d_p(5)_d_p(6),d)
	i ERR=0  w "c  PASS",!
	s ITEM="$piece(",ERR=0 
	s d="hi there",p="xx"
	d EXAM(ITEM_d_",p)  p = ""xx""",$p(d,p),d)
	i ERR=0  w "d  PASS",!
	s ITEM="$piece(",ERR=0 
	s d="hi there"
	d EXAM(ITEM_d_",xx)",$p(d,"xx"),d)
	i ERR=0  w "e  PASS",!
	q

arg2(s,D) d EXAM(ITEM_s_","_D_")",$p(s,D),P(d))
	q

arg3(s,D) new k
	s ITEM=ITEM_s_","_D_","
	f k=-1:1:7  d EXAM(ITEM_k_")",$p(s,D,k),p(k))
	q

arg4(s,D) new i,j,TEM,EM
	s TEM=ITEM_s_","_D_","
	f i=-1:1:7 s vs="",EM=TEM_i_"," f j=-1:1:7 d
	.	s:(j'<i) vs=vs_p(j)  
	.	d EXAM(EM_j_")",$p(s,D,i,j),vs)
	.	s:(j<6)&(vs'="") vs=vs_D
	q

EXAM(LAB,VCOMP,VCORR)
	i VCOMP=VCORR q
	s ERR=ERR+1
	w " ** FAIL in ",LAB,!
	w ?10,"CORRECT  =",VCORR,!
	w ?10,"COMPUTED =",VCOMP,!
	q
