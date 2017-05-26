fnextr	; Test range of values for optional arguments in $EXTRACT
	s i=-1,str="ABC"
loop	d inloop s i=i+1 i i<5 g loop
	q
inloop	s j=-1
inl1	d proc s j=j+1 i j<5 g inl1
	q
proc	w i," ",j," ","'",$e(str,i,j),"'",!
