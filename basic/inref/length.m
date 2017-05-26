length	; Test of $LENGTH function
	w !,"Test of $length function",!
	s ITEMA="in $length(string) constructed from "
	s ITEMB="in $length(str,del) constructed from "
	s x="",ERR=0
	s l=$l(x,"|") d:l'=1 FAIL(ITEMB_" an empty string",l,1)  
	f j=0:1:127  s l=$l(x),x=x_$c(j)  d:j'=l FAIL(ITEMB_j_" characters",l,j) 
	s r=128,m=1
	f k=1:1:7  d
	.	s l=$l(x,"|")             d:l'=(m+1) FAIL(ITEMB_m_" pieces",l,m+1)  
	.	s x=x_x,r=r+r,l=$l(x)         d:l'=r FAIL(ITEMA_k_"*128+"_j,l,r) 
	.	s m=m+m
	s x=x_$e(x,1,(l-128)),r=r+r-128
	f j=0:1:126 s x=x_$c(j),r=r+1,l=$l(x) d:l'=r FAIL(ITEMA_r_"characters ",l,r) 
	i ERR=0 w "l  PASS",!
	q

FAIL(LAB,VCOMP,VCORR)
	s ERR=ERR+1
	w " ** FAIL ",LAB,!
	w ?10,"CORRECT  =",VCORR,!
	w ?10,"COMPUTED =",VCOMP,!
	q
