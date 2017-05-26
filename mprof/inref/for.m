for	; Test of FOR loop
	new st,ERR,ITEM
	w !,"Test of for loop",!
	s ERR=0,ITEM="f  q:k=0 ... f  q:j=1 ... "
	
noargq	s k=-.1,j=64
	f  q:k=0  s k=k+.1  f  q:j=1  s j=j/2
	do EXAM(ITEM_"k",k,0)
	do EXAM(ITEM_"j",j,1)
	i ERR=0  w "q  PASS",!

noargg	s k=-.1,j=4,ERR=0
	f  g:k=0 exam  s k=k+.1  f  g:j=1 exam  s j=j-1
exam	do EXAM(ITEM_"k",k,0)
	do EXAM(ITEM_"j",j,1)
	i ERR=0  w "g  PASS",!

list	s ITEM="f k=a,b,c ...",ERR=0
	f k="a",k_"b",k_"c"  s k=k_"*"
	do EXAM(ITEM,k,"a*b*c*")
	i ERR=0  w "l  PASS",!

indxstep
	s ITEM="s x=0  f k=indx:step:limit  s x=x+1",ERR=0
	s x=0
	f k=-1:1:1  f j=1:-1:-1  s x=x+1
	do EXAM(ITEM,x,9)
	i ERR=0  w "+x PASS",!

	s ITEM="s x=0  f k=indx:step:limit  s x=x+1",ERR=0
	s x=0
	f k=-1:1  q:x=9  f j=1:-1:-1  s x=x+1
	do EXAM(ITEM,k,2)
	i ERR=0  w "-x PASS",!

long
	s ITEM="s x=0  f k=999999:1:1000000  s x=x+1",ERR=0
	s x=0
	f k=999999:1:1000000  s x=x+1
	do EXAM(ITEM,x,2)
	i ERR=0  w "+m PASS",!

	s ITEM="s x=0  f k=-999999:-1:-1000000  s x=x+1",ERR=0
	s x=0
	f k=-999999:-1:-1000000  s x=x+1
	do EXAM(ITEM,x,2)
	i ERR=0  w "-m PASS",!

conv	s ITEM="s x=0  f k=0:1:1.001 s k=k+.0005  s x=x+1",ERR=0
	s x=0
	f k=0:1:1.001  s k=k+.0005  s x=x+1
	do EXAM(ITEM,x,2)
	do EXAM(ITEM,k,1.001)
	i ERR=0  w "+c PASS",!

	s ITEM="s x=0  f k=1:-1:-2.002 s k=k-.0005  s x=x+1",ERR=0
	s x=0
	f k=1:-1:-2.002  s k=k-.0005  s x=x+1
	do EXAM(ITEM,x,4)
	do EXAM(ITEM,k,-2.002)
	i ERR=0  w "-c PASS",!
	q

EXAM(item,vcomp,vcorr)
	i vcorr=vcomp  q
	w " ** FAIL in ",item,!
	w ?10,"CORRECT  = ",vcorr,!
	w ?10,"COMPUTED = ",vcomp,!
	s ERR=ERR+1
	q
