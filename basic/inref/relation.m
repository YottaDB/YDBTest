relation	; Test of relational operators
	w !,"Test of relational operations",!
	s v(0)=0,v(1)=0_7E-15,v(2)="0.029",v(3)="01",v(4)=220,v(5)=229.041
	s v(6)=4096.3444,v(7)=4096.3449,v(8)=999990,v(9)=9999930,v(10)=9999997799E14
	s ITEMA="comparing ",ITEMB="comparing @"
	s ERR=0
	f i=0:1:10  f j=0:1:10  do numcomp(v(i),v(j)),numcomp(-v(j),-v(i)),lexcomp(v(i),v(j),0)
	i ERR=0  w "a  PASS",!
	s ERR=0
	f i=0:-1:-10  f j=0:1:10  do numcomp(-v(-i),v(j))
	i ERR=0  w "b  PASS",!
	s w(-1)="",w(11)="@Now is the time",w(12)="X",w(13)="now"
	s ERR=0,i=0
	f k=-1,11,12,13  f j=0:1:10  do numcomp(w(k),v(j))
	i ERR=0  w "c  PASS",!
	s ERR=0
	f i=-1,11,12,13  f j=0:1:10  do lexcomp(w(i),v(j),"")
	i ERR=0  w "d  PASS",!
	q

numcomp(a,b)
	new k,r
	s r=i<j  f k=(a<b),'(a'<b) do:k'=r FAIL(ITEMA_a_"<"_b,k,r)
	s r=i>j  f k=(a>b),'(a'>b) do:k'=r FAIL(ITEMA_a_">"_b,k,r)
	s r=i'<j f k=(a'<b),'(a<b) do:k'=r FAIL(ITEMA_a_"'<"_b,k,r)
	s r=i'>j f k=(a'>b),'(a>b) do:k'=r FAIL(ITEMA_a_"'>"_b,k,r)
	s r=i<j  f k="p=a<b","p='(a'<b)" s @k  do:p'=r FAIL(ITEMB_a_"<"_b,p,r)
	s r=i>j  f k="p=a>b","p='(a'>b)" s @k  do:p'=r FAIL(ITEMB_a_">"_b,p,r)
	s r=i'<j f k="p=a'<b","p='(a<b)" s @k  do:p'=r FAIL(ITEMB_a_"'<"_b,p,r)
	s r=i'>j f k="p=a'>b","p='(a>b)" s @k  do:p'=r FAIL(ITEMB_a_"'>"_b,p,r)
	q

lexcomp(a,b,B)
	new k,r
	s r=i=j  f k=(a=b),'(a'=b) do:k'=r FAIL(ITEMA_a_"="_b,k,r)
	s r=i'=j f k=(a'=b),'(a=b) do:k'=r FAIL(ITEMA_a_"'="_b,k,r)
	s r=i>j  f k=(a]b),'(a']b) do:k'=r FAIL(ITEMA_a_"]"_b,k,r)
	s r=i'>j f k=(a']b),'(a]b) do:k'=r FAIL(ITEMA_a_"']"_b,k,r)
	s r=(b=B)!(i=j) f k=(a[b),'(a'[b) do:k'=r FAIL(ITEMA_a_"["_b,k,r)
	s r=(b'=B)&(i'=j) f k=(a'[b),'(a[b) do:k'=r FAIL(ITEMA_a_"'["_b,k,r)
	s r=i=j  f k="p=a=b","p='(a'=b)" s @k  do:p'=r FAIL(ITEMB_a_"="_b,p,r)
	s r=i'=j f k="p=a'=b","p='(a=b)" s @k  do:p'=r FAIL(ITEMB_a_"'="_b,p,r)
	s r=i>j  f k="p=a]b","p='(a']b)" s @k  do:p'=r FAIL(ITEMB_a_"]"_b,p,r)
	s r=i'>j f k="p=a']b","p='(a]b)" s @k  do:p'=r FAIL(ITEMB_a_"']"_b,p,r)
	s r=(b'=B)&(i'=j) f k="p=a'[b","p='(a[b)" s @k  do:p'=r FAIL(ITEMB_a_"'["_b,p,r)
	s r=(b=B)!(i=j)  f k="p=a[b","p='(a'[b)" s @k  do:p'=r FAIL(ITEMB_a_"["_b,p,r)
	q

FAIL(LAB,VCOMP,VCORR)
	s ERR=ERR+1
	w " ** FAIL ",LAB,!
	w ?10,"CORRECT  =",VCORR,!
	w ?10,"COMPUTED =",VCOMP,!
	q
